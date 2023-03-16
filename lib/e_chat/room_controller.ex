defmodule EChat.RoomController do

  alias EChat.Struct.Response
  alias EChat.Struct.Room
  alias EChat.RoomsServer

  import EChat.RoomSupervisor, only: [start_work: 1]
  import EChat.RoomServer, only: [get_messages: 1]

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
    %Room{name: roomname, creator: username}
    |> start_work
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

  defp post_room_response({:error, :complicated}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: ""}, 400, cowboy_request), []}
  end
end
