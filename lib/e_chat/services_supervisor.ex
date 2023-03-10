defmodule EChat.ServicesSupervisor do
  use Supervisor

  def start_link(_args) do
    IO.puts "Starting the services supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      EChat.UserServer,
      EChat.RoomSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
