defmodule EChat.RoomController do

  alias EChat.RoomServer
  alias EChat.Struct.Response
  alias EChat.Struct.Room
  alias EChat.Struct.Message
  alias EChat.RoomsServer

  import EChat.RoomSupervisor, only: [start_work: 1]
  import EChat.RoomServer, only: [get_messages: 1]
  import EChat.UserServer, only: [get_user: 1]

  @doc """
  For getting a room.
  """
  def get_room(roomname, cowboy_request) do
    roomname
    |> URI.decode
    |> get_messages
    |> get_room_response(cowboy_request)
  end

  defp get_room_response({:ok, {roomname, messages}}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Success", messages: messages, roomname: roomname}, 200, cowboy_request), []}
  end

  defp get_room_response({:error, :not_found}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Not Found"}, 404, cowboy_request), []}
  end

  defp get_room_response(_, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: ""}, 400, cowboy_request), []}
  end

  @doc """
  For getting a list of all the room names
  """
  def get_rooms(cowboy_request) do
    RoomsServer.get_roomnames()
    |> get_rooms_response(cowboy_request)
  end

  defp get_rooms_response({:ok, rooms}, cowboy_request) do
    body = %{msg: "Success", rooms: rooms}

    {:ok, Response.generate_json_response(body, 200, cowboy_request), []}
  end

  @doc """
  For posting a room. Starts the room process.
  """
  def post_room(roomname, username, cowboy_request) do
    case get_user(username) do
      {:error, :not_found} -> {:error, :creator_not_found}
      _user -> %Room{name: roomname, creator: username}
        |> start_work
    end
    |> post_room_response(cowboy_request)
  end

  defp post_room_response({:ok, _}, cowboy_request) do
    RoomsServer.update_sockets()
    {:ok, Response.generate_json_response(%{msg: "Created"}, 201, cowboy_request), []}
  end

  defp post_room_response({:error, :already_started}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Duplicate name"}, 400, cowboy_request), []}
  end

  defp post_room_response({:error, :creator_not_found}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "User not found"}, 404, cowboy_request), []}
  end

  defp post_room_response({:error, _}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: ""}, 400, cowboy_request), []}
  end

  @doc """
  For posting a message to a room.
  """
  def post_message(roomname, username, message, cowboy_request) do
    case get_user(username) do
      {:error, :not_found} ->
        {:error, :creator_not_found}
      _user ->
        RoomServer.set_message(roomname |> URI.decode, %Message{username: username, message: message})
    end
    |> post_message_response(cowboy_request)
  end

  defp post_message_response({:ok, {roomname, _message}}, cowboy_request) do
    RoomServer.update_sockets(roomname)
    {:ok, Response.generate_json_response(%{msg: "Created"}, 201, cowboy_request), []}
  end

  defp post_message_response({:error, :not_found}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Not Found"}, 404, cowboy_request), []}
  end

  defp post_message_response({:error, :creator_not_found}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "User not found"}, 404, cowboy_request), []}
  end
end
