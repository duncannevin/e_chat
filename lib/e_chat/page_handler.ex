defmodule EChat.PageHandler do
  @moduledoc """
  Handles page requests;
  """

  alias EChat.Struct.Request

  import EChat.PageView, only: [get_page: 1, handle_file: 2]

  @pages_path Path.expand("../../pages", __DIR__)

  def init(req, _state), do: req
  |> Request.from_cowboy
  |> handle

  defp handle(%Request{method: "GET", path: "/", cowboy: cowbow_request}) do
    get_page("index")
    |> handle_file(cowbow_request)
  end
end
