defmodule EChat.Util do
  def pidify(room_name), do: Process.whereis room_name
end
