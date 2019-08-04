defmodule VidFeederWeb.PageController do
  use VidFeederWeb, :controller

  def index(conn, _params) do
    data =
      static_dir
      |> Path.join("index.html")
      |> File.read!()

    conn
    |> put_resp_content_type("text/html")
    |> resp(:ok, data)
    |> send_resp
  end

  defp static_dir do
    Application.app_dir(:vidfeeder, "priv/static")
  end
end
