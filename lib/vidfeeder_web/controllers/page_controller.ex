defmodule VidFeederWeb.PageController do
  use VidFeederWeb, :controller

  def index(conn, _params) do
    feeds = VidFeeder.Repo.all(VidFeeder.Feed)

    render conn, "index.html", feeds: feeds
  end
end
