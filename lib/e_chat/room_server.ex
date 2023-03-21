defmodule EChat.RoomServer do

  use GenServer

  alias EChat.Struct.Room
  alias EChat.Struct.Message
  alias EChat.Struct.WsResponse
  alias EChat.Util
  alias Elixir.Process

  defmodule State do
    defstruct room: %Room{}, socket_pids: []
  end

  def start_link(%Room{} = room) do
    GenServer.start_link(__MODULE__, %State{room: room}, name: String.to_atom(room.name))
  end

  # Client interface

  def get_messages(roomname) do
    roomname
    |> Util.to_atom
    |> Util.whereis_then(
      & GenServer.call(&1, :get_messages)
    )
  end

  def set_message(roomname, %Message{} = message) do
    roomname
    |> Util.to_atom
    |> Util.whereis_then(
      & GenServer.call(&1, {:set_message, message})
    )
  end

  def register_socket(roomname, socket_pid) do
    roomname
    |> Util.to_atom
    |> GenServer.cast({:register_socket, socket_pid})
  end

  def update_sockets(roomname) do
    roomname
    |> Util.to_atom
    |> GenServer.cast({:update_sockets})
  end

  # Server callbacks

  def handle_call(:get_messages, _from, %State{room: room} = state) do
    {:reply, {:ok, {room.name, room.messages}}, state}
  end

  def handle_call({:set_message, message}, _from, %State{room: room, socket_pids: _socket_pids} = state) do
    updated_room = %Room{room | messages: [message | room.messages]}
    new_state = %State{state | room: updated_room}
    {:reply, {:ok, {room.name, updated_room.messages}}, new_state}
  end

  def handle_cast({:register_socket, socket_pid}, %State{socket_pids: socket_pids, room: room} = state) do
    IO.puts "Registering a socket in room #{inspect room.name} #{inspect socket_pid}"
    new_state = %State{state | socket_pids: [socket_pid | socket_pids]}
    {:noreply, new_state}
  end

  def handle_cast({:update_sockets}, %State{room: room, socket_pids: socket_pids} = state) do
    IO.inspect socket_pids
    new_state = %State{state | socket_pids: socket_pids}

    for pid <- new_state.socket_pids do
      IO.puts "Emitting updated room for room #{inspect room.name}"
      Process.send(pid, WsResponse.as_json("room", room), [])
    end

    {:noreply, new_state}
  end

  def init(%State{room: room} = state) do
    IO.puts "Starting the #{inspect room} room server..."
    {:ok, state}
  end
end
