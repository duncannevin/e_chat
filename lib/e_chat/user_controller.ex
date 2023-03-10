defmodule EChat.UserController do

  alias EChat.UserServer
  alias EChat.Struct.Response
  alias EChat.UserServer

  @doc """
  For getting a user.
  """
  def get_user(username, cowboy_request) do
    username
    |> UserServer.get_user
    |> get_user_response(cowboy_request)
  end

  defp get_user_response({:ok, user}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Success", user: user}, 200, cowboy_request), []}
  end

  defp get_user_response({:error, :not_found}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Not found"}, 404, cowboy_request), []}
  end

  @doc """
  For create a user.
  """
  def create_user(username, cowboy_request) do
    username
    |> UserServer.create_user
    |> create_user_response(cowboy_request)
  end

  defp create_user_response({:ok, user}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Created", user: user}, 201, cowboy_request), []}
  end

  defp create_user_response({:error, :duplicate, username}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Duplicate", username: username}, 400, cowboy_request), []}
  end

  @doc """
  For getting all the users
  """
  def get_users(cowboy_request) do
    UserServer.get_users
    |> get_users_response(cowboy_request)
  end

  defp get_users_response({:ok, users}, cowboy_request) do
    {:ok, Response.generate_json_response(%{msg: "Success", users: users}, 200, cowboy_request), []}
  end
end
