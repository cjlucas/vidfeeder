defmodule VidFeederWeb.PageController do
  use VidFeederWeb, :controller

  def index(conn, _params) do
    data = File.read!("priv/static/index.html")

    conn
    |> put_resp_content_type("text/html")
    |> resp(:ok, data)
    |> send_resp
  end
end
