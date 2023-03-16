defmodule EChat.RoomsServer do

  @name :rooms_server

  use GenServer

  alias EChat.Struct.WsResponse

  import EChat.RoomSupervisor, only: [get_room_names: 0]

  defmodule State do
    defstruct socket_pids: []
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    IO.puts "Starting the rooms server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  # Client Interface
  def get_roomnames do
    GenServer.call @name, {:get_roomnames}
  end

  def register_socket(socket_pid) do
    GenServer.cast @name, {:register_socket, socket_pid}
  end

  def update_sockets do
    GenServer.cast @name, {:update_sockets}
  end

  # Server Callbacks

  def handle_call({:get_roomnames}, _from, state) do
    {:reply, get_room_names(), state}
  end

  def handle_cast({:register_socket, socket_pid}, %State{socket_pids: socket_pids} = state) do
    IO.puts "Registering a socket in the rooms server #{inspect socket_pid}"
    new_state = %State{state | socket_pids: [socket_pid | socket_pids]}
    {:noreply, new_state}
  end

  def handle_cast({:update_sockets}, %State{socket_pids: socket_pids} = state) do
    IO.inspect socket_pids
    new_state = %State{state | socket_pids: socket_pids}
    {:ok, roomnames} = get_room_names()

    IO.puts "Emitting updated roomnames"

    for pid <- new_state.socket_pids do
      Process.send(pid, WsResponse.as_json("roomnames", roomnames), [])
    end

    {:noreply, new_state}
  end

  def init(%State{} = state) do
    {:ok, state}
  end
end
