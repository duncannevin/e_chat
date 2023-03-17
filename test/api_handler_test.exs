defmodule ApiHandlerTest do
  use ExUnit.Case

  import Mock

  alias EChat.ApiHandler

  alias EChat.RoomController
  alias EChat.UserController
  alias EChat.Struct.Response
  alias EChat.Struct.Request

  @response {:ok, %Response{body: %{msg: "Mock Response"}} |> Poison.encode!, []}

  describe "init /api/room" do
    test  "POST /api/room" do
      with_mock RoomController, [
        post_room:
          fn(_roomname, _creator, _cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "POST", body: %{}, path: "/api/room", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end

    test  "POST /api/room/message/roomname" do
      with_mock RoomController, [
        post_message:
          fn(_roomname, _creator, _message, _cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "POST", body: %{}, path: "/api/room/message/roomname", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end

    test  "GET /api/room" do
      with_mock RoomController, [
        get_rooms:
          fn(_cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "GET", body: %{}, path: "/api/room", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end

    test  "GET /api/room/roomname" do
      with_mock RoomController, [
        get_room:
          fn(_roomname, _cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "GET", body: %{}, path: "/api/room/roomname", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end
  end

  describe "init /api/user" do
    test  "POST /api/user" do
      with_mock UserController, [
        create_user:
          fn(_username, _cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "POST", body: %{}, path: "/api/user", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end

    test  "GET /api/user" do
      with_mock UserController, [
        get_users:
          fn(_cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "GET", body: %{}, path: "/api/user", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end

    test  "GET /api/user/username" do
      with_mock UserController, [
        get_user:
          fn(_username, _cowboy_request) ->
            @response
          end
        ] do
          req = %Request{method: "GET", body: %{}, path: "/api/user/username", cowboy: %{}}
          assert ApiHandler.init(req, []) == @response
      end
    end
  end

  describe "init fall through" do
    test "not found response" do
      with_mock Response, [
        generate_json_response:
          fn(_body, _status, _cowboy_request) ->
            %{body: "Mock Cowboy Response"}
          end
      ] do
        req = %Request{method: "GET", body: %{}, path: "/not/a/route", cowboy: %{}}
        assert ApiHandler.init(req, []) == {:ok, %{body: "Mock Cowboy Response"}, []}
      end
    end
  end
end
