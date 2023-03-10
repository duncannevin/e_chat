defmodule EChat.Struct.Request do
  defstruct has_body: false,
  headers: %{},
  host: "",
  method: "",
  path: "",
  body: nil,
  cowboy: %{}

  def from_cowboy(cowboy_req) do
    body = cowboy_req
    |> parse_body

    %__MODULE__{
      has_body: cowboy_req.has_body,
      headers: cowboy_req.headers,
      host: cowboy_req.host,
      method: cowboy_req.method,
      path: cowboy_req.path,
      body: body,
      cowboy: cowboy_req
    }
  end

  defp parse_body(%{
      has_body: true,
      headers: %{"content-type" => "application/json"}
    } = cowboy) do
    {:ok, raw_body, _} = :cowboy_req.read_body(cowboy)

    Poison.Parser.parse!(raw_body, %{})
  end

  defp parse_body(%{
      headers: %{"content-type" => "application/x-www-form-urlencoded"}
    } = cowboy) do
    {:ok, raw_body, _} = :cowboy_req.read_urlencoded_body(cowboy)

    decode_url_encoded_body(raw_body)
  end

  defp parse_body(_cowboy) do
    %{}
  end

  defp decode_url_encoded_body(raw, body \\ %{})
  defp decode_url_encoded_body([], body), do: body
  defp decode_url_encoded_body([{key, value} | rest], body), do: decode_url_encoded_body(rest, Map.put(body, key, value))
end
