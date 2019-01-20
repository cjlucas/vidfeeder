defmodule VidFeeder.SourceImporter.YouTubeChannelImporter do
  alias VidFeeder.{
    Repo,
    YouTubeChannel,
    YouTubePlaylist
  }

  alias VidFeeder.SourceImporter.YouTubePlaylistImporter

  def run(youtube_channel) do
    youtube_channel = Repo.preload(youtube_channel, :uploads_playlist)
    conn = YouTube.Connection.new
    
    case YouTube.Channel.info(conn, youtube_channel.channel_id) do
      nil ->
        nil

      channel ->
        playlist =
          channel
          |> find_or_create_uploads_playlist
          |> YouTubePlaylistImporter.run

        youtube_channel
        |> YouTubeChannel.api_changeset(channel)
        |> Ecto.Changeset.put_assoc(:uploads_playlist, playlist)
        |> Repo.update!
    end
  end

  defp find_or_create_uploads_playlist(channel) do
    uploads_playlist_id = channel.related_playlists[:uploads]

    uploads_playlist =
      case Repo.get_by(YouTubePlaylist, playlist_id: uploads_playlist_id) do
        nil ->
          YouTubePlaylist.create_changeset(uploads_playlist_id) |> Repo.insert!

        playlist ->
          playlist
      end
  end
end
