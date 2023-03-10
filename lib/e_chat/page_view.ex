defmodule EChat.PageView do
  @pages_path Path.expand("../../pages", __DIR__)

  alias EChat.Struct.Response

  def get_page(page_name) do
    @pages_path
      |> Path.join(page_name <> ".html")
      |> File.read
  end

  def handle_file({:ok, content}, cowboy_request) do
    res = %Response{
      headers: %{"content-type" => "text/html"},
      body: content
    }
    |> Response.to_cowboy(cowboy_request)

    {:ok, res, []}
  end

  def handle_file({:error, :enoent}, cowboy_request) do
    res = %Response{
      headers: %{"content-type" => "text/html"},
      body: """
        <html>
          <body>
            <p>Not Found</p>
          </body>
        </html>
      """
    }
    |> Response.to_cowboy(cowboy_request)

    {:not_found, res, []}
  end

  def handle_file({:error, reason}, cowboy_request) do
    res = %Response{
      headers: %{"content-type" => "text/html"},
      body: """
        <html>
          <body>
            <p>Uh oh, we did somthing wrong.</p>
            #{inspect reason}
          </body>
        </html>
      """
    }
    |> Response.to_cowboy(cowboy_request)

    {:internal_server_error, res, []}
  end
end
