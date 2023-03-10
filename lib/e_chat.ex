defmodule EChat do
  @moduledoc """
  `EChat` is Duncan's first elixir project from scratch. It's just a chat application, make a room, join a room, chat.
  """

  use Application

  @doc """
  Start this application here.
  """
  def start(_type, _arg) do
    IO.puts "Starting EChat...."
    EChat.HttpServer.start()
    EChat.Supervisor.start_link()
  end
end
