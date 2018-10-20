defmodule VidFeederWeb.FeedController do
  use VidFeederWeb, :controller

  alias VidFeeder.{
    Feed,
    Repo
  }

  def rss(conn, params) do
    IO.inspect params
    feed = Repo.get(Feed, params["id"]) |> Repo.preload(:items)

    render conn, "show.rss", feed: feed
  end
end
