defmodule VidFeederWeb.API.FeedController do
  use VidFeederWeb, :controller

  @long_poll_timeout        10 * 1000
  @long_poll_retry_interval 500
  @long_poll_retry_count    div(@long_poll_timeout, @long_poll_retry_interval)

  alias VidFeeder.{
    ImportFeedWorker,
    Feed,
    Repo
  }

  def create(conn, params) do
    try do
      feed =
        %Feed{}
        |> Feed.create_changeset(params)
        |> Repo.insert!

      ImportFeedWorker.import_feed(feed)

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
        feed = wait_for_feed_metadata(feed)

        if feed_metadata_exists?(feed) do
          render conn, "show.json", feed: feed
        else
          conn
          |> put_status(:accepted)
          |> render("show.json", feed: feed)
        end
    end
  end

  defp feed_metadata_exists?(feed) do
    feed.title != nil
  end

  defp wait_for_feed_metadata(feed), do: wait_for_feed_metadata(feed, @long_poll_retry_count)
  defp wait_for_feed_metadata(feed, 0), do: feed
  defp wait_for_feed_metadata(feed, n) do
    if feed_metadata_exists?(feed) do
      feed
    else
      Process.sleep(@long_poll_retry_interval)

      feed = Repo.get(Feed, feed.id)
      wait_for_feed_metadata(feed, n - 1)
    end
  end

  defp put_location_header(conn, feed) do
    feed_url = VidFeederWeb.Router.Helpers.feed_url(conn, :show, feed.id)
    put_resp_header(conn, "location", feed_url)
  end
end
