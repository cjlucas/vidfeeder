defmodule VidFeeder.SourceImporter.YouTubePlaylistImporter do
  alias VidFeeder.{
    Repo,
    YouTubePlaylist,
    YouTubeVideo,
    YouTubeVideoMetadataManager
  }

  alias Ecto.Multi

  import Ecto.Query

  use Log

  def run(youtube_playlist) do
    conn = YouTube.Connection.new()

    case YouTube.Playlist.info(conn, youtube_playlist.playlist_id) do
      nil ->
        Log.debug("YouTube playlist cannot be found", playlist_id: youtube_playlist.playlist_id)

      playlist ->
        if youtube_playlist.etag != playlist.etag do
          Log.info("Etag mismatch", old_etag: youtube_playlist.etag, new_tag: playlist.etag)

          youtube_playlist = Repo.preload(youtube_playlist, :items)
          playlist_items = YouTube.Playlist.items(conn, playlist.id)
          videos = YouTube.Video.get(conn, Enum.map(playlist_items, &Map.get(&1, :video_id)))

          Multi.new()
          |> Multi.run(:insert_videos, fn _acc -> {:ok, insert_videos(videos)} end)
          |> Multi.run(:insert_playlist_items, fn %{insert_videos: videos} ->
            playlist_items = insert_playlist_items(youtube_playlist, playlist_items, videos)
            {:ok, playlist_items}
          end)
          |> Multi.run(
            :delete_orphaned_playlist_items,
            fn %{insert_playlist_items: youtube_playlist_items} ->
              {:ok, delete_orphaned_playlist_items(youtube_playlist_items)}
            end
          )
          |> Multi.update(
            :update_playlist,
            YouTubePlaylist.api_changeset(youtube_playlist, playlist)
          )
          |> Multi.run(:fetch_video_metadata, fn %{update_playlist: youtube_playlist} ->
            fetch_video_metadata(youtube_playlist)

            {:ok, nil}
          end)
          |> Repo.transaction()

          youtube_playlist
        else
          Log.info("Etag is the same, won't parse further")

          youtube_playlist
        end
    end
  end

  def insert_videos(videos) do
    Enum.map(videos, fn video ->
      VidFeeder.YouTubeVideo.build(video.id)
      |> VidFeeder.YouTubeVideo.api_changeset(video)
      |> Repo.insert!(
        on_conflict: :replace_all,
        conflict_target: :video_id
      )
    end)
  end

  def insert_playlist_items(youtube_playlist, playlist_items, videos) do
    video_id_lut =
      Enum.reduce(videos, %{}, fn video, acc -> Map.put(acc, video.video_id, video.id) end)

    playlist_items =
      Enum.map(playlist_items, fn playlist_item ->
        video_id = Map.get(video_id_lut, playlist_item.video_id)

        if is_nil(video_id) do
          IO.inspect(playlist_item)
          raise "Received a playlist item with an unkown video id: #{playlist_item.video_id}"
        end

        result =
          VidFeeder.YouTubePlaylistItem.build(youtube_playlist, playlist_item.id)
          |> VidFeeder.YouTubePlaylistItem.api_changeset(playlist_item)
          |> Ecto.Changeset.put_change(:video_id, video_id)
          |> Repo.insert(
            on_conflict: [set: [position: playlist_item.position]],
            conflict_target: :playlist_item_id
          )

        case result do
          {:ok, playlist_item} ->
            Log.debug("Created playlist item: #{playlist_item.id}")
            playlist_item

          {:error, error} ->
            Log.debug("Failed to insert playlist item: #{playlist_item.id} #{inspect(error)}")

            nil
        end
      end)
  end

  def delete_orphaned_playlist_items(youtube_playlist_items) do
    playlist_item_ids = Enum.map(youtube_playlist_items, &Map.get(&1, :playlist_item_id))

    from(i in VidFeeder.YouTubePlaylistItem,
      where: i.playlist_item_id not in ^playlist_item_ids
    )
    |> Repo.delete_all()
  end

  defp fetch_video_metadata(youtube_playlist) do
    youtube_playlist.items
    |> Enum.map(fn playlist_item -> playlist_item.video end)
    |> Enum.filter(fn youtube_video -> youtube_video.mime_type == nil end)
    |> Enum.filter(&YouTubeVideo.available_in_united_states?/1)
    |> YouTubeVideoMetadataManager.process_videos()
  end
end
