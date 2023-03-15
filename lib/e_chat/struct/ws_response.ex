defmodule EChat.Struct.WsResponse do
  defstruct action: "none", data: []

  def as_json(action, data), do: %__MODULE__{
    action: action,
    data: data
  }
  |> Poison.encode!
end
