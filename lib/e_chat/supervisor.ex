defmodule EChat.Supervisor do
  @moduledoc """
  This is the top level supervisor for EChat.
  """

  @name :supervisor

  use Supervisor

  def start_link() do
    IO.puts "Starting the main superviser..."
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      EChat.ServicesSupervisor,
      EChat.RoomsServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
