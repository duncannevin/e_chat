defmodule EChat.RoomSupervisor do
  use DynamicSupervisor

  alias EChat.Struct.Room

  def start_link(_args) do
    IO.puts "Starting the room supervisor..."
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Client interface

  def start_work(%Room{} = room) do
    supervise_room(room)
  end

  def get_room_names do
    {:ok, DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn ({_, pid, _, _}) -> [{_, name} | _] = Process.info(pid)
      name
    end)}
  end

  defp supervise_room(%Room{} = room) do
    spec = {EChat.RoomServer, room}
    DynamicSupervisor.start_child(__MODULE__, spec)
    |> handle_supervision_response
  end

  # Server callbacks

  defp handle_supervision_response({:ok, pid}), do: {:ok, pid}
  defp handle_supervision_response({:error, {:already_started, _}}), do: {:error, :already_started}
  defp handle_supervision_response({:error, error}), do: IO.inspect error; {:error, :complicated}

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
