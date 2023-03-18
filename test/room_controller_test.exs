defmodule RoomControllerTest do
  use ExUnit.Case

  import Mock

  alias EChat.RoomSupervisor
  alias EChat.RoomServer
  alias EChat.RoomsServer
  alias EChat.UserServer
  alias EChat.Struct.Response
  alias EChat.RoomController
  alias EChat.Struct.User
  alias EChat.Struct.Room
  alias EChat.Struct.Message

  setup_with_mocks([
      {
        Response,
        [],
        [
          generate_json_response:
            fn (response, status, _cowboy_request) ->
              {response, status}
            end
        ]
      },
      {
        RoomsServer,
        [],
        [
          update_sockets: fn () -> nil end
        ]
      },
      {
        RoomServer,
        [],
        [
          update_sockets: fn (_roomname) -> nil end,
          set_message:
            fn (roomname, message) ->
              {:ok, {roomname, message}}
            end
        ]
      },
      {
        UserServer,
        [],
        [
          get_user: fn (username) -> %User{username: username} end
        ]
      }
    ]) do
      IO.puts "Mocks setup"
  end

  describe "get_room" do
    test "should return 200 response" do
      with_mock(
        RoomServer,
        [
          get_messages:
            fn (roomname) ->
              {:ok, {roomname, []}}
            end
        ]
      ) do
        res = %{msg: "Success", messages: [], roomname: "room name"}
        status = 200
        assert RoomController.get_room("room name", %{}) == {:ok, {res, status}, []}
      end
    end

    test "should return Not Found response" do
      with_mock(
        RoomServer,
        [
          get_messages:
            fn (_roomname) ->
              {:error, :not_found}
            end
        ]
      ) do
        res = %{msg: "Not Found"}
        status = 404
        assert RoomController.get_room("room name", %{}) == {:ok, {res, status}, []}
      end
    end

    test "should return 400 response" do
      with_mock(
        RoomServer,
        [
          get_messages:
            fn (_roomname) ->
              {:umh, :ya}
            end
        ]
      ) do
        res = %{msg: ""}
        status = 400
        assert RoomController.get_room("room name", %{}) == {:ok, {res, status}, []}
      end
    end
  end

  describe "get_rooms" do
    test "should return 200 response" do
      with_mock(
        RoomsServer,
        [
          get_roomnames:
            fn () ->
              {:ok, []}
            end
        ]
      ) do
        res = %{msg: "Success", rooms: []}
        status = 200
        assert RoomController.get_rooms(%{}) == {:ok, {res, status}, []}
      end
    end
  end

  describe "post_room" do
    test "should return 200 response and start the room process" do
      with_mock(
        RoomSupervisor,
        [
          start_work:
            fn (%Room{name: _roomname, creator: _username}) ->
              {:ok, []}
            end
        ]
      ) do
        res = %{msg: "Created"}
        status = 201
        assert RoomController.post_room("room name", "chester", %{}) == {:ok, {res, status}, []}
        assert_called RoomsServer.update_sockets()
      end
    end

    test "should return 400 duplicate and not update sockets" do
      with_mock(
        RoomSupervisor,
        [
          start_work:
            fn (%Room{name: _roomname, creator: _username}) ->
              {:error, :already_started}
            end
        ]
      ) do
        res = %{msg: "Duplicate name"}
        status = 400
        assert RoomController.post_room("room name", "chester", %{}) == {:ok, {res, status}, []}
        assert_not_called RoomsServer.update_sockets()
      end
    end

    test "should return 404 when the user is not found and not update sockets" do
      with_mocks([
        {
          RoomSupervisor,
          [],
          [
            start_work:
              fn (%Room{name: _roomname, creator: _username}) ->
                {:error, :already_started}
              end
          ]
        },
        {
          UserServer,
          [],
          [
            get_user: fn (_username) -> {:error, :not_found} end
          ]
        }
      ]) do
        res = %{msg: "User not found"}
        status = 404
        assert RoomController.post_room("room name", "chester", %{}) == {:ok, {res, status}, []}
        assert_not_called RoomsServer.update_sockets()
      end
    end

    test "should return 400 as default and not update sockets" do
      with_mock(
        RoomSupervisor,
        [
          start_work:
            fn (%Room{name: _roomname, creator: _username}) ->
              {:error, :complicated}
            end
        ]
      ) do
        res = %{msg: ""}
        status = 400
        assert RoomController.post_room("room name", "chester", %{}) == {:ok, {res, status}, []}
        assert_not_called RoomsServer.update_sockets()
      end
    end
  end

  describe "post_message" do
    test "should return 201 response and update the rooms sockets" do
      res = %{msg: "Created"}
      status = 201
      msg = %Message{username: "chester", message: "hey!"}
      assert RoomController.post_message("room name", "chester", msg, %{}) == {:ok, {res, status}, []}
      assert_called RoomServer.update_sockets("room name")
    end

    test "should return 404 when the user is not found and not update sockets" do
      with_mocks([
        {
          UserServer,
          [],
          [
            get_user: fn (_username) -> {:error, :not_found} end
          ]
        }
      ]) do
        res = %{msg: "User not found"}
        status = 404
        msg = %Message{username: "chester", message: "hey!"}
        assert RoomController.post_message("room name", "chester", msg, %{}) == {:ok, {res, status}, []}
        assert_not_called RoomServer.update_sockets("room name")
      end
    end

    test "should return 404 when the room is not found and not update sockets" do
      with_mocks([
        {
          RoomServer,
          [],
          [
            set_message: fn (_roomname, _message) -> {:error, :not_found} end
          ]
        }
      ]) do
        res = %{msg: "Not Found"}
        status = 404
        msg = %Message{username: "chester", message: "hey!"}
        assert RoomController.post_message("room name", "chester", msg, %{}) == {:ok, {res, status}, []}
        assert_not_called RoomServer.update_sockets("room name")
      end
    end
  end
end
