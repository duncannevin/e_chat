defmodule EChat.WsHandler do
  @behaviour :cowboy_websocket

  alias EChat.RoomsServer
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

  def websocket_init(%State{server: :rooms, name: nil} = state) do
    RoomsServer.register_socket(self())
    {:ok, state}
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
    IO.puts "Terminating a socket for some #{inspect reason}. #{inspect state}"
    :ok
  end

  defp server_from_path(path) do
    case path |> String.split("/") do
      [_, _ws, s, n] -> {String.to_atom(s), n |> URI.decode |> String.to_atom}
      [_, _ws, s] -> {String.to_atom(s), nil}
      _ -> [nil, nil]
    end
  end
end
