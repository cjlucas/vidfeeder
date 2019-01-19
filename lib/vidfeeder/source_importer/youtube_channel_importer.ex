defmodule VidFeeder.SourceImporter.YouTubeChannelImporter do
  alias VidFeeder.{
    Repo,
    YouTubeChannel,
    YouTubePlaylist
  }

  alias VidFeeder.SourceImporter.YouTubePlaylistImporter

  require Logger

  def run(youtube_channel) do
    youtube_channel = Repo.preload(youtube_channel, :uploads_playlist)
    conn = YouTube.Connection.new
    channel = YouTube.Channel.info(conn, youtube_channel.channel_id)
    uploads_playlist_id = channel.related_playlists[:uploads]

    uploads_playlist =
      case Repo.get_by(YouTubePlaylist, playlist_id: uploads_playlist_id) do
        nil ->
          YouTubePlaylist.build(uploads_playlist_id) |> Repo.insert!

        playlist ->
          playlist
      end

    playlist = YouTubePlaylistImporter.run(uploads_playlist)

    youtube_channel
    |> YouTubeChannel.api_changeset(channel)
    |> Ecto.Changeset.put_assoc(:uploads_playlist, playlist)
    |> Repo.update!
  end
end
