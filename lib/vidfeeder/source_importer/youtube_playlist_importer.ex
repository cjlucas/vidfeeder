defmodule VidFeeder.SourceImporter.YouTubePlaylistImporter do
  alias VidFeeder.{Repo, YouTubePlaylist, YouTubeVideo}

  import Ecto.Query

  require Logger

  defmodule YouTubePlaylistItemsDiffer do
    def diff(youtube_playlist_items, playlist_items) do
      {youtube_playlist_items_ids, youtube_playlist_items_map} =
        build_cache(youtube_playlist_items, :playlist_item_id)

      {playlist_items_ids, playlist_items_map} =
        build_cache(playlist_items, :id)

      new_items =
        playlist_items_ids
        |> MapSet.difference(youtube_playlist_items_ids)
        |> Enum.map(fn id ->
          {:new, playlist_items_map[id]}
        end)

      existing_items =
        playlist_items_ids 
        |> MapSet.intersection(youtube_playlist_items_ids)
        |> Enum.map(fn id ->
          playlist_item = playlist_items_map[id]
          {:existing, youtube_playlist_items_map[id], playlist_item}
        end)

      new_items ++ existing_items
    end

    defp build_cache(collection, key) do
      ids = collection |> Enum.map(&Map.get(&1, key)) |> MapSet.new

      map = Enum.reduce(collection, %{}, fn item, acc ->
        key = Map.get(item, key)

        Map.put(acc, key, item)
      end)

      {ids, map}
    end
  end

  def run(youtube_playlist) do
    conn = YouTube.Connection.new

    case YouTube.Playlist.info(conn, youtube_playlist.playlist_id) do
      nil ->
        Logger.debug("YouTube playlist cannot be found: #{youtube_playlist.playlist_id}")
      playlist ->
        IO.inspect(playlist)

        if youtube_playlist.etag != playlist.etag do
          Logger.debug("Etag mismatch")

          with {:ok, youtube_playlist} <- update_playlist(youtube_playlist, playlist),
               {:ok, youtube_playlist} <- update_playlist_items(conn, youtube_playlist) do
            youtube_playlist
          end

        else
          Logger.debug("Etag is the same, won't parse further")

          youtube_playlist
        end
    end
  end

  def update_playlist(youtube_playlist, playlist) do
    youtube_playlist
    |> YouTubePlaylist.api_changeset(playlist)
    |> Repo.update
  end

  def update_playlist_items(conn, youtube_playlist) do
    playlist_items = YouTube.Playlist.items(conn, youtube_playlist.playlist_id)

    youtube_videos_by_video_id =
      conn
      |> create_or_update_videos_from_playlist_items(playlist_items)
      |> Enum.reduce(%{}, fn video, acc -> Map.put(acc, video.video_id, video) end)

    youtube_playlist = Repo.preload(youtube_playlist, youtube_playlist_items: :youtube_video)

    youtube_playlist_items =
      youtube_playlist.youtube_playlist_items
      |> YouTubePlaylistItemsDiffer.diff(playlist_items)
      |> Enum.map(fn
        {:new, playlist_item} ->
          youtube_playlist
          |> VidFeeder.YouTubePlaylistItem.build(playlist_item.id)
          |> VidFeeder.YouTubePlaylistItem.from_api_changeset(playlist_item)
          |> Ecto.Changeset.put_assoc(:youtube_video, youtube_videos_by_video_id[playlist_item.video_id])

        {:existing, youtube_playlist_item, playlist_item} ->
          youtube_playlist_item
          |> VidFeeder.YouTubePlaylistItem.from_api_changeset(playlist_item)
          |> Ecto.Changeset.put_assoc(:youtube_video, youtube_videos_by_video_id[playlist_item.video_id])
      end)

    youtube_playlist = 
      youtube_playlist
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:youtube_playlist_items, youtube_playlist_items)
      |> Repo.update!

    {:ok, youtube_playlist}
  end

  defp create_or_update_videos_from_playlist_items(conn, playlist_items) do
    video_ids = playlist_items |> Enum.map(&Map.get(&1, :video_id))
    videos = YouTube.Video.get(conn, video_ids)

    {:ok, existing_videos_by_video_id} = Repo.transaction(fn ->
      (from v in YouTubeVideo, 
       where: v.video_id in ^video_ids)
       |> Repo.stream
       |> Enum.reduce(%{}, fn video, acc ->
         Map.put(acc, video.video_id, video)
       end)
    end)

    Enum.map(videos, fn video ->
      case Map.get(existing_videos_by_video_id, video.id) do
        nil ->
          video.id
          |> YouTubeVideo.build
          |> YouTubeVideo.from_api_changeset(video)
          |> Repo.insert!

        youtube_video ->
          youtube_video
          |> YouTubeVideo.from_api_changeset(video)
          |> Repo.update!
      end
    end)
  end
end
