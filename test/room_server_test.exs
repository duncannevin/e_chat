defmodule RoomServerTest do
  use ExUnit.Case

  import Mock

  alias EChat.Struct.Room
  alias EChat.Struct.Message
  alias EChat.Struct.WsResponse
  alias EChat.RoomServer
  alias EChat.Util
  alias Elixir.Process

  setup_with_mocks([
    {
      GenServer,
      [],
      [
        start_link: fn (_module, _state, [name: _name]) -> nil end,
        call: fn (_pid, _message) -> nil end,
        cast: fn (_pid, _message) -> nil end
      ]
    },
    {
      Util,
      [],
      [
        whereis_then: fn (_name, then_fn) -> then_fn.(self()) end,
        to_atom: fn (value) -> value end
      ]
    },
    {
      Process,
      [],
      [
        send: fn (_pid, _data, _option) -> nil end
      ]
    }
  ]) do
    IO.puts "Room Server Test Mocks Setup"
  end

  describe "start_link" do
    test "should start the link" do
      room = %Room{name: "a room"}
      RoomServer.start_link(room)
      assert_called(GenServer.start_link(RoomServer, %RoomServer.State{room: room}, name: String.to_atom(room.name)))
    end
  end

  describe "get_messages" do
    test "should handle a binary roomname" do
      roomname = "binary roomname"
      RoomServer.get_messages(roomname)
      assert_called(Util.to_atom(roomname))
    end

    test "should emit a call to the roomname" do
      roomname = :"binary roomname"
      RoomServer.get_messages(roomname)
      assert_called(GenServer.call(self(), :get_messages))
    end
  end

  describe "set_message" do
    test "should handle a binary roomname" do
      roomname = "binary roomname"
      msg = %Message{message: "a message"}
      RoomServer.set_message(roomname, msg)
      assert_called(Util.to_atom(roomname))
    end

    test "should emit a call to the roomname" do
      roomname = :"binary roomname"
      msg = %Message{message: "a message"}
      RoomServer.set_message(roomname, msg)
      assert_called(GenServer.call(self(), {:set_message, msg}))
    end
  end

  describe "register_socket" do
    test "should handle a binary roomname" do
      roomname = "binary roomname"
      socket_pid = self()
      RoomServer.register_socket(roomname, socket_pid)
      assert_called(Util.to_atom(roomname))
    end

    test "should emit a call to the roomname" do
      roomname = :"binary roomname"
      socket_pid = self()
      RoomServer.register_socket(roomname, socket_pid)
      assert_called(GenServer.cast(roomname, {:register_socket, socket_pid}))
    end
  end

  describe "update_sockets" do
    test "should handle a binary roomname" do
      roomname = "binary roomname"
      RoomServer.update_sockets(roomname)
      assert_called(Util.to_atom(roomname))
    end

    test "should emit a call to the roomname" do
      roomname = :"binary roomname"
      RoomServer.update_sockets(roomname)
      assert_called(GenServer.cast(roomname, {:update_sockets}))
    end
  end

  describe "handle_call" do
    test ":get_messages should respond with correct data" do
      state = %RoomServer.State{room: %Room{name: "room", messages: []}}
      res = RoomServer.handle_call(:get_messages, [], state)
      assert res == {:reply, {:ok, {state.room.name, state.room.messages}}, state}
    end

    test "{:set_message, message} should respond with correct data" do
      room = %Room{name: "room", messages: []}
      state = %RoomServer.State{room: room}
      message = %Message{message: "message", username: "chester"}
      res = RoomServer.handle_call({:set_message, message}, [], state)
      expected_state = %RoomServer.State{state | room: %Room{room | messages: [message]}}
      assert res == {:reply, {:ok, {state.room.name, [message]}}, expected_state}
    end

    test "{:register_socket, socket_pid} should respond with correct data" do
      socket_pid = self()
      state = %RoomServer.State{}
      res = RoomServer.handle_cast({:register_socket, socket_pid}, state)
      expected_state = %RoomServer.State{state | socket_pids: [socket_pid]}
      assert res == {:noreply, expected_state}
    end

    test "{:update_sockets} should respond with correct data" do
      state = %RoomServer.State{}
      res = RoomServer.handle_cast({:update_sockets}, state)
      assert res == {:noreply, state}
    end

    # TODO: figure out why the Process mock is not working here.
    # test "{:update_sockets} should send to each pid in socket_pids" do
    #   room = %Room{name: "room", messages: []}
    #   state = %RoomServer.State{socket_pids: [1, 2, 3, 4], room: room}
    #   RoomServer.handle_cast({:update_sockets}, state)
    #   assert_called_exactly(Process.send(:_, :_, []), 4)
    # end
  end

  describe "init" do
    test "should return the initial state" do
      room = %Room{name: "room", messages: []}
      socket_pid = self()
      state = %RoomServer.State{room: room, socket_pids: [socket_pid]}
      res = RoomServer.init(state)
      assert res == {:ok, state}
    end
  end
end
