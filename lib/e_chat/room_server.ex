defmodule EChat.RoomServer do

  use GenServer

  alias EChat.Struct.Room
  alias EChat.Struct.Message

  import Process, only: [whereis: 1]

  def start_link(%Room{} = room) do
    GenServer.start_link(__MODULE__, room, name: String.to_atom(room.name))
  end

  # Client interface

  def get_messages(room_name) when is_binary(room_name) do
    room_name
    |> String.to_atom
    |> get_messages
  end

  def get_messages(room_name) do
    case whereis room_name do
      nil -> {:error, :not_found}
      pid -> GenServer.call(pid, :get_messages)
    end
  end

  def set_message(room_name, %Message{} = message) do
    case whereis room_name do
      nil -> {:error, :not_found}
      pid -> GenServer.call(pid, {:set_message, message})
    end
  end

  # Server callbacks

  def handle_call(:get_messages, _from, state) do
    {:reply, {:ok, {state.name, state.messages}}, state}
  end

  def handle_call({:set_message, message}, _from, state) do
    new_state = %Room{state | messages: [message | state.messages]}
    {:reply, {:ok, {state.name, new_state.messages}}, new_state}
  end

  def init(%Room{} = room) do
    IO.puts "Starting the #{inspect room} room server..."
    {:ok, room}
  end
end
