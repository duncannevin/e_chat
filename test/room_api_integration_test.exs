defmodule RoomApiIntegrationTest do
  use ExUnit.Case

  @port 8080
  @api_path "http://localhost:#{inspect @port}/api"

  describe "POST /api/room" do
    test "should start a process for the passed in room" do
      username = "freddy"
      EChat.UserServer.create_user(username)
      room_name = "Test Room"
      {:ok, response} = do_post("/room", %{roomname: room_name, username: username})

      assert response.status_code == 201
      assert response.body == "{\"msg\":\"Created\"}"
      assert Process.whereis(String.to_atom(room_name)) != nil
    end

    test "should respond with User not found message" do
      room_name = "Test Room"
      {:ok, response} = do_post("/room", %{roomname: room_name, username: "notauser"})

      assert response.status_code == 404
      assert response.body == "{\"msg\":\"User not found\"}"
    end

    test "should respond with a duplicate name message" do
      username = "freddy"
      EChat.UserServer.create_user(username)
      room_name = "Test Roomba"
      {:ok, response1} = do_post("/room", %{roomname: room_name, username: username})

      assert response1.body == "{\"msg\":\"Created\"}"
      assert response1.status_code == 201

      {:ok, response2} = do_post("/room", %{roomname: room_name, username: username})

      assert response2.body == "{\"msg\":\"Duplicate name\"}"
      assert response2.status_code == 400
    end
  end

  describe "GET /api/room" do
    test "should get a list of room names" do
      username = "freddy"
      EChat.UserServer.create_user(username)
      room_one = "Room One"
      room_two = "Room Two"
      {:ok, _} = do_post("/room", %{roomname: room_one, username: username})
      {:ok, _} = do_post("/room", %{roomname: room_two, username: username})

      {:ok, response} = do_get("/room")

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 200
      assert parsed_body["msg"] == "Success"
      assert parsed_body["rooms"] |> Enum.all?
    end
  end

  describe "GET /api/room/<Room Name>" do
    test "should get a specific room" do
      username = "freddy"
      EChat.UserServer.create_user(username)
      room_to_find = "Room To Find"
      {:ok, _} = do_post("/room", %{roomname: room_to_find, username: username})

      {:ok, response} = do_get("/room/" <> room_to_find)

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 200
      assert parsed_body["msg"] == "Success"
      assert parsed_body["roomname"] == room_to_find
      assert parsed_body["messages"] == []
    end

    test "should reply with not found" do
      room_to_find = "The Room To Find"

      {:ok, response} = do_get("/room/" <> room_to_find)

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 404
      assert parsed_body["msg"] == "Not Found"
    end
  end

  describe "GET /not/a/route" do
    test "should reply with not found" do
      {:ok, response} = do_get("/not/a/route")

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 404
      assert parsed_body["msg"] == "Not Found"
    end
  end

  def do_get(path) do
    path
    |> make_path
    |> HTTPoison.get(%{"content-type" => "application/json"})
  end

  def do_post(path, body) do
    path
    |> make_path
    |> HTTPoison.post(
      Poison.encode!(body),
      %{"content-type" => "application/json"})
  end

  def make_path(path), do: @api_path <> path
  |> URI.encode
end
