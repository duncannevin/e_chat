defmodule EChat.ApiHandler do
  @moduledoc """
  Handles are requests that begin with the path "/api"
  """

  import EChat.RoomController, only: [get_room: 2, get_rooms: 1, post_room: 3, post_message: 4]
  import EChat.UserController, only: [get_user: 2, create_user: 2, get_users: 1]

  alias EChat.Struct.Request
  alias EChat.Struct.Response

  def init(req, _state), do: req
  |> Request.from_cowboy
  |> handle

  # "/api/room" routes

  defp handle(%Request{method: "POST", body: body, path: "/api/room", cowboy: cowboy_request}) do
    roomname = body["roomname"]
    creator = body["username"]
    post_room(roomname, creator, cowboy_request)
  end

  defp handle(%Request{method: "POST", path: "/api/room/message/" <> roomname, body: body, cowboy: cowboy_request}) do
    creator = body["username"]
    message = body["message"]

    post_message(roomname, creator, message, cowboy_request)
  end

  defp handle(%Request{method: "GET", path: "/api/room", cowboy: cowboy_request}) do
    get_rooms(cowboy_request)
  end

  defp handle(%Request{method: "GET", path: "/api/room/" <> roomname, cowboy: cowboy_request}) do
    get_room(roomname, cowboy_request)
  end

  # "/api/user" routes

  defp handle(%Request{method: "POST", body: body, path: "/api/user", cowboy: cowboy_request}) do
    username = body["username"]
    create_user(username, cowboy_request)
  end

  defp handle(%Request{method: "GET", path: "/api/user", cowboy: cowboy_request}) do
    get_users(cowboy_request)
  end

  defp handle(%Request{method: "GET", path: "/api/user/" <> username, cowboy: cowboy_request}) do
    get_user(username, cowboy_request)
  end

  # Default fall through

  defp handle(%Request{cowboy: cowboy_request}) do
    {:ok, Response.generate_json_response(%{msg: "Not Found"}, 404, cowboy_request), []}
  end
end
