defmodule EChat.HttpServer do
  @moduledoc """
  HTTP Server built using [ninenines/Cowboy](https://github.com/ninenines/cowboy),
  """

  def start(port \\ Application.get_env(:e_chat, :port))
  def start(port) do
    IO.puts "Starting the HTTP server on port #{port}..."
    {:ok, pid} = :cowboy.start_clear(
      100,
      [{:port, port}],
      %{env: %{dispatch: config()}}
    )
    pid
  end

  defp config do
    :cowboy_router.compile([
      {
        # Matches all paths.
        :_, [
          # Pathmatch "/static/[...]".
          # Serves statice files from the static files directory.
          {"/static/[...]", :cowboy_static, {:priv_dir, :e_chat, "static_files"}},
          # Pathmatch "/api/[...]"
          # Handles api requests.
          {"/api/[...]", EChat.ApiHandler, []},
          # Pathmatch "/ws"
          # Handles ws requests.
          {"/ws", EChat.WsHandler, []},
          # Pathmatch "/[...]".
          # Serves the pages.
          {"/[...]", EChat.PageHandler, []},
        ]
      }
    ])
  end
end
