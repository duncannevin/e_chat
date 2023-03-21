defmodule RoomSupervisorTest do
  use ExUnit.Case

  import Mock

  alias EChat.RoomSupervisor
  alias EChat.Struct.Room

  setup_with_mocks([
    {
      DynamicSupervisor,
      [],
      [
        start_link: fn (_module, _state, [name: _name]) -> nil end
      ]
    },
    {
      IO,
      [],
      [
        puts: fn (_log) -> :ok end,
        inspect: fn (_thing) -> nil end
      ]
    }
  ]) do
    IO.puts "Mocks initialized"
  end

  describe "start_link" do
    test "should log" do
      RoomSupervisor.start_link([])
      assert_called(IO.puts "Starting the room supervisor...")
    end

    test "shoudl start the link" do
      RoomSupervisor.start_link([])
      assert_called(DynamicSupervisor.start_link(RoomSupervisor, :ok, name: RoomSupervisor))
    end
  end

  describe "start_work" do
    test "should supervise the room" do
      with_mock(
        DynamicSupervisor,
        [
          start_child: fn (_module, _spec) -> {:ok, self()} end
        ]
      ) do
        assert RoomSupervisor.start_work(%Room{}) == {:ok, self()}
      end
    end

    test "should handle an already start room gracefully" do
      with_mock(
        DynamicSupervisor,
        [
          start_child: fn (_module, _spec) -> {:error, {:already_started, self()}} end
        ]
      ) do
        assert RoomSupervisor.start_work(%Room{}) == {:error, :already_started}
      end
    end

    test "should handle errors" do
      with_mock(
        DynamicSupervisor,
        [
          start_child: fn (_module, _spec) -> {:error, :test_error} end
        ]
      ) do
        assert RoomSupervisor.start_work(%Room{}) == {:error, :test_error}
      end
    end
  end
end
