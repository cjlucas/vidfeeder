defmodule VidFeederWeb.RssController do
  use VidFeederWeb, :controller

  alias VidFeeder.{
    Feed,
    Repo
  }

  def show(conn, params) do
    IO.inspect params
    feed = Repo.get(Feed, params["id"]) |> Repo.preload(:items)

    render conn, "show.rss", feed: feed
  end
end
