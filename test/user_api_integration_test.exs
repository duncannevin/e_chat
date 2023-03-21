defmodule UserApiIntegrationTest do
  use ExUnit.Case

  @port 8080
  @api_path "http://localhost:#{inspect @port}/api"

  describe "POST /api/user" do
    test "should create a user" do
      username = "chestertester"
      {:ok, response} = do_post("/user", %{username: username})

      assert response.status_code == 201
      assert response.body == "{\"user\":{\"username\":\"chestertester\"},\"msg\":\"Created\"}"
    end

    test "should respond with a duplicate name message" do
      username = "fuzzy"
      {:ok, response1} = do_post("/user", %{username: username})

      assert response1.body == "{\"user\":{\"username\":\"fuzzy\"},\"msg\":\"Created\"}"
      assert response1.status_code == 201

      {:ok, response2} = do_post("/user", %{username: username})

      assert response2.body == "{\"username\":\"fuzzy\",\"msg\":\"Duplicate\"}"
      assert response2.status_code == 400
    end
  end

  describe "GET /api/user" do
    test "should get a list of users" do
      username_one = "duncan"
      username_two = "sally"
      {:ok, _} = do_post("/user", %{username: username_one})
      {:ok, _} = do_post("/user", %{username: username_two})

      {:ok, response} = do_get("/user")

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 200
      assert parsed_body["msg"] == "Success"
    end
  end

  describe "GET /api/user/<User Name>" do
    test "should get a specific user" do
      username = "bobby"
      {:ok, _} = do_post("/user", %{username: username})

      {:ok, response} = do_get("/user/" <> username)

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 200
      assert parsed_body["msg"] == "Success"
      assert parsed_body["user"] == %{"username" => username}
    end

    test "should reply with not found" do
      {:ok, response} = do_get("/user/notauser")

      parsed_body = Poison.Parser.parse!(response.body)

      assert response.status_code == 404
      assert parsed_body["msg"] == "Not found"
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
