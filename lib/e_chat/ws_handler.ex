defmodule EChat.WsHandler do
  @behaviour :cowboy_websocket

  alias EChat.RoomServer

  defmodule State do
    defstruct server: :not_set, name: :not_set
  end

  def init(req, _state) do
    {server, name} = server_from_path(req.path)
    state = %State{server: server, name: name}

    {:cowboy_websocket, req, state}
  end

  def websocket_init(%State{server: :room, name: name} = state) do
    case RoomServer.register_socket(name, self()) do
      {:error, _} -> {:error, :not_found}
      _ -> {:ok, state}
    end
  end

  def websocket_handle(_handle, state) do
    {:reply, {:text, "hello world"}, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  def terminate(reason, _req, %State{server: :room, name: :room1}) do
    IO.puts "Terminating room socket: :room1, #{inspect reason}"
    :ok
  end

  def terminate(reason, _req, state) do
    IO.puts "Terminating a socket for some #{reason}. #{inspect state}"
    :ok
  end

  defp server_from_path(path) do
    [_, _ws, server, name] = path
    |> String.split("/")

    {String.to_atom(server), name |> URI.decode |> String.to_atom}
  end
end
