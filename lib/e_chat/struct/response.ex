defmodule EChat.Struct.Response do
  defstruct status: 200, body: "", headers: %{"content-type" => "text/html"}

  def to_cowboy(%__MODULE__{} = res, cowboy_request), do: :cowboy_req.reply(
    res.status,
    res.headers,
    res.body,
    cowboy_request
  )

  def not_found(%__MODULE__{} = res, cowboy_request), do: to_cowboy(%__MODULE__{res | status: 404}, cowboy_request)

  def generate_json_response(body, status, cowboy_request, headers \\ %{})
  def generate_json_response(body, status, cowboy_request, headers) do
    %__MODULE__{
      headers: Map.put(headers, "content-type", "application/json"),
      body: Poison.encode!(body),
      status: status
    }
    |> to_cowboy(cowboy_request)
  end
end
