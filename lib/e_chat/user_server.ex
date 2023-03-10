defmodule EChat.UserServer do

  @name :user_server

  use GenServer

  alias EChat.Struct.User

  defmodule State do
    defstruct users: %{}
  end

  def start_link(_arg) do
    IO.puts "Starting the user server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  # Client interfaces

  def create_user(username) do
    GenServer.call @name, {:create_user, username}
  end

  def get_user(username) do
    GenServer.call @name, {:get_user, username}
  end

  def get_users do
    GenServer.call @name, {:get_users}
  end

  # Server callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_info(message, state) do
    IO.puts "!! #{inspect message}"
    {:noreply, state}
  end

  def handle_call({:get_users}, _from, state) do
    {:reply, {:ok, Map.values(state.users)}, state}
  end

  def handle_call({:get_user, username}, _from, state) do
    case Map.get(state.users, username) do
      nil -> {:reply, {:error, :not_found}, state}
      user -> {:reply, {:ok, user}, state}
    end
  end

  def handle_call({:create_user, username}, _from, state) do
    case Map.get(state.users, username) do
      nil ->
        user = %User{username: username}
        new_state = %State{state | users: Map.put(state.users, username, user)}
        {:reply, {:ok, user}, new_state}
      _user -> {:reply, {:error, :duplicate, username}, state}
    end
  end

  def handle_call(_call) do
    {:reply, {:error, :nutso}}
  end
end
