defmodule VidFeederWeb.API.FeedController do
  use VidFeederWeb, :controller

  import Ecto.Query

  @long_poll_timeout        10 * 1000
  @long_poll_retry_interval 500
  @long_poll_retry_count    div(@long_poll_timeout, @long_poll_retry_interval)

  alias VidFeeder.{
    ImportFeedWorker,
    Feed,
    Repo,
    Source,
    SourceImporter,
    YouTubeUser,
    YouTubeChannel,
    YouTubePlaylist
  }

  def create(conn, params) do
    try do
      feed =
        %Feed{}
        |> Feed.create_changeset(params)
        |> Repo.insert!

      ImportFeedWorker.import_feed(feed)

      underlying_source =
        case {params["source"], params["source_type"]} do
          {"youtube", "user"} ->
            YouTubeUser.build(params["source_id"])

          {"youtube", "channel"} ->
            YouTubeChannel.build(params["source_id"])

          {"youtube", "playlist"} ->
            YouTubePlaylist.build(params["source_id"])
        end

      if underlying_source != nil do
          source =
            underlying_source
            |> Source.build
            |> Map.put(:id, feed.id)
            |> Repo.insert!
      end

      conn
      |> put_location_header(feed)
      |> send_resp(:created, "")
    rescue
      e in Ecto.ConstraintError ->
        %{constraint: constraint} = e

        if constraint == "feeds_source_source_type_source_id_index" do
          feed = Repo.get_by!(
            Feed,
            source: params["source"],
            source_type: params["source_type"],
            source_id: params["source_id"]
          )

          conn
          |> put_location_header(feed)
          |> send_resp(:see_other, "")
        else
          raise e
        end
    end
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Feed, id) do
      nil ->
        send_resp(conn, :not_found, "")
      feed ->
        feed = wait_for_feed_items(feed)

        if feed_items_exist?(feed) do
          render conn, "show.json", feed: feed
        else
          conn
          |> put_status(:accepted)
          |> render("show.json", feed: feed)
        end
    end
  end

  defp feed_items_exist?(feed) do
    Repo.one(from fi in "feeds_items",
             select: count(fi.item_id),
             where: fi.feed_id == type(^feed.id, Ecto.UUID)) > 0
  end

  defp wait_for_feed_items(feed), do: wait_for_feed_items(feed, @long_poll_retry_count)
  defp wait_for_feed_items(feed, 0), do: feed
  defp wait_for_feed_items(feed, n) do
    if feed_items_exist?(feed) do
      feed
    else
      Process.sleep(@long_poll_retry_interval)

      feed = Repo.get(Feed, feed.id)
      wait_for_feed_items(feed, n - 1)
    end
  end

  defp put_location_header(conn, feed) do
    feed_url = VidFeederWeb.Router.Helpers.feed_url(conn, :show, feed.id)
    put_resp_header(conn, "location", feed_url)
  end
end
