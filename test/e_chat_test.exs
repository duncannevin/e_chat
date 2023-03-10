defmodule EChatTest do
  use ExUnit.Case
  doctest EChat

  test "greets the world" do
    assert EChat.hello() == :world
  end
end
