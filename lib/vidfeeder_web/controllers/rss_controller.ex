defmodule VidFeederWeb.RssController do
  use VidFeederWeb, :controller

  alias VidFeeder.{
    Source,
    Repo,
    FeedGenerator
  }

  def show(conn, params) do
    feed = Repo.get(Source, params["id"]) |> FeedGenerator.generate

    render conn, "show.rss", feed: feed
  end
end
