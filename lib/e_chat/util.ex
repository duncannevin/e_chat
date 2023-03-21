defmodule EChat.Util do
  def pidify(room_name), do: Process.whereis room_name

  def whereis_then(name, then_fn) do
    case Process.whereis name do
      nil -> {:error, :not_found}
      pid -> then_fn.(pid)
    end
  end

  def to_atom(str) when is_atom(str), do: str
  def to_atom(str), do: String.to_atom(str)
end
