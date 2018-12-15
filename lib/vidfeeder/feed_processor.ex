defmodule VidFeeder.FeedProcessor do # TODO: rename to FeedImporter
  import Ecto.Query

  alias VidFeeder.{
    Repo,
    Feed,
    Item
  }

  def run(feed) do
    IO.puts("Importing feed: #{feed.id}")

    case {feed.source, feed.source_type} do
      {"youtube", "channel"} ->
        conn = YouTube.Connection.new

        channel_info = YouTube.Channel.info(conn, feed.source_id)
        feed
        |> Feed.changeset(%{
          title: channel_info.title,
          description: channel_info.description,
          image_url: channel_info.image_url
        })
        |> Repo.update!

        items = YouTube.Channel.uploads(conn, feed.source_id)
        update_feed_items!(feed, items)
      {"youtube", "user"} ->
        conn = YouTube.Connection.new
        
        user_info = YouTube.User.info(conn, feed.source_id)
        feed
        |> Feed.changeset(%{
          title: feed.source_id,
          description: user_info.description,
          image_url: user_info.image_url
        })
        |> Repo.update!

        items = YouTube.User.uploads(conn, feed.source_id)
        update_feed_items!(feed, items)
      {"youtube", "playlist"} ->
        conn = YouTube.Connection.new
        
        playlist_info = YouTube.Playlist.info(conn, feed.source_id)
        feed
        |> Feed.changeset(%{
          title: playlist_info.title,
          description: playlist_info.description,
          image_url: playlist_info.image_url
        })
        |> Repo.update!

        items = YouTube.Playlist.videos(conn, feed.source_id)
        update_feed_items!(feed, items)
    end
  end

  def update_feed_items!(feed, items) do
    source_ids = Enum.map(items, &Map.get(&1, :id))
    query = from item in Item, where: item.source_id in ^source_ids

    existing_items_by_source_id =
      query
      |> Repo.all
      |> Enum.reduce(%{}, fn item, acc ->
        Map.put(acc, item.source_id, item)
      end)

    {new_items, existing_items} =
      Enum.reduce(items, {[], []}, fn item, {new_items, existing_items} ->
        case Map.get(existing_items_by_source_id, item.id) do
          nil ->
            item = Repo.insert!(%Item{
              title: item.title,
              description: item.description,
              source_id: item.id,
              duration: item.duration,
              image_url: item.image_url,
              published_at: item.published_at
            })

            {[item | new_items], existing_items}
          existing_item ->
            item =
              existing_item
              |> Ecto.Changeset.change(%{
                title: item.title,
                description: item.description,
                duration: item.duration,
                image_url: item.image_url,
                published_at: item.published_at
              })
              |> Repo.update!

            {new_items, [item | existing_items]}
        end
      end)

    changeset =
      feed
      |> Repo.preload(:items)
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_change(:last_refreshed_at, DateTime.utc_now)
      |> Ecto.Changeset.put_change(:state, "imported")
      |> Ecto.Changeset.put_assoc(:items, new_items ++ existing_items)

    IO.puts("UPDATING feed: #{feed.id}")

    Repo.update!(changeset)

    IO.puts "FETCHING METADATA"

    chunk_by =
      if Enum.count(new_items) > 100 do
        div(Enum.count(new_items), 100)
      else
        1
      end

    new_items
    |> Enum.chunk_every(chunk_by)
    |> Enum.map(fn chunk ->
      Task.async(fn ->
        Enum.each(chunk, fn item -> fetch_item_metadata(item) end)
      end)
    end)
    |> Enum.each(&Task.await(&1, :infinity))
  end
  
  def fetch_item_metadata(item) do
    video_url = "https://www.youtube.com/watch?v=#{item.source_id}"
    url = "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"

    IO.puts "REQUEST"

    case HTTPoison.head(url, [], follow_redirect: true, timeout: 20_000, recv_timeout: 20_000) do
      {:ok, %{status_code: 200} = resp} ->
        %{"Content-Type" => mime_type, "Content-Length" => size} = Enum.into(resp.headers, %{})

        IO.puts "SUCCESS"

        item
        |> Ecto.Changeset.change(%{
          mime_type: mime_type,
          size: size
        })
        |> VidFeeder.Repo.update!
      {:ok, resp} ->
        IO.puts "UNKNOWN RESPONSE"
        IO.inspect resp
      {:error, err} ->
        IO.puts "ERROR #{inspect err}"
        nil
    end
  end
end
