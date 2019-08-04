defmodule VidFeederWeb.API.FeedController do
  use VidFeederWeb, :controller

  import Ecto.Query

  @long_poll_timeout 10 * 1000
  @long_poll_retry_interval 500
  @long_poll_retry_count div(@long_poll_timeout, @long_poll_retry_interval)

  alias VidFeeder.{
    ImportFeedWorker,
    Feed,
    Repo,
    Source,
    SourceScheduler,
    SourceEventManager,
    FeedGenerator,
    YouTubeUser,
    YouTubeChannel,
    YouTubePlaylist
  }

  def create(conn, params) do
    {underlying_source_changeset, get_existing} =
      case {params["source"], params["source_type"]} do
        {"youtube", "user"} ->
          {
            YouTubeUser.create_changeset(params["source_id"]),
            fn -> Repo.get_by(YouTubeUser, username: params["source_id"]) end
          }

        {"youtube", "channel"} ->
          {
            YouTubeChannel.create_changeset(params["source_id"]),
            fn -> Repo.get_by(YouTubeChannel, channel_id: params["source_id"]) end
          }

        {"youtube", "playlist"} ->
          {
            YouTubePlaylist.create_changeset(params["source_id"]),
            fn -> Repo.get_by(YouTubePlaylist, playlist_id: params["source_id"]) end
          }
      end

    if underlying_source_changeset != nil do
      result =
        Repo.transaction(fn ->
          case Repo.insert(underlying_source_changeset) do
            {:ok, underlying_source} ->
              source = underlying_source |> Source.build() |> Repo.insert!()
              SourceScheduler.process_source(source)
              source

            {:error, _} ->
              nil
          end
        end)

      case result do
        {:error, _} ->
          case get_existing.() do
            nil ->
              send_resp(conn, 500, "i dunno")

            underlying_source ->
              source = Repo.preload(underlying_source, :source).source

              conn
              |> put_location_header(source)
              |> send_resp(:see_other, "")
          end

        {:ok, source} ->
          conn
          |> put_location_header(source)
          |> send_resp(:created, "")
      end
    end
  end

  def show(conn, %{"id" => id}) do
    {:ok, _} = SourceEventManager.register(:source_processed, id)

    case Repo.get(Source, id) do
      nil ->
        send_resp(conn, :not_found, "")

      source ->
        if source.state in ["initial", "processing"] do
          case wait_for_processing(id) do
            {:ok, source} ->
              feed = FeedGenerator.generate(source)
              render(conn, "show.json", feed: feed)

            {:error, :timeout} ->
              feed = FeedGenerator.generate(source)

              conn
              |> put_status(:accepted)
              |> render("show.json", feed: feed)
          end
        else
          feed = FeedGenerator.generate(source)
          render(conn, "show.json", feed: feed)
        end
    end
  end

  defp wait_for_processing(source_id), do: wait_for_processing(source_id, @long_poll_timeout)

  defp wait_for_processing(source_id, timeout) do
    start = System.monotonic_time(:millisecond)

    receive do
      {:source_processed, ^source_id} ->
        source = Repo.get(Source, source_id)
        {:ok, source}

      _ ->
        now = System.monotonic_time(:millisecond)
        wait_for_processing(source_id, now - start)
    after
      timeout ->
        {:error, :timeout}
    end
  end

  defp put_location_header(conn, source) do
    feed_url = VidFeederWeb.Router.Helpers.feed_url(conn, :show, source.id)
    put_resp_header(conn, "location", feed_url)
  end
end
