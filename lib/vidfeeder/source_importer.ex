defmodule VidFeeder.SourceImporter do
  alias VidFeeder.{
    Repo,
    Source,
    YouTubeUser,
    YouTubeChannel,
    YouTubePlaylist
  }

  alias VidFeeder.SourceImporter.{
    YouTubePlaylistImporter,
    YouTubeChannelImporter,
    YouTubeUserImporter
  }

  @underlying_sources [
    :youtube_user,
    :youtube_channel,
    :youtube_playlist
  ]

  def run(source) do
    source = Repo.preload(source, @underlying_sources)

    case underlying_source(source) do
      %YouTubeUser{} = user ->
        YouTubeUserImporter.run(user)

      %YouTubeChannel{} = channel ->
        YouTubeChannelImporter.run(channel)

      %YouTubePlaylist{} = playlist ->
        YouTubePlaylistImporter.run(playlist)
    end

    source
    |> Source.changeset(%{state: "processed", last_refreshed_at: DateTime.utc_now})
    |> Repo.update!
  end

  defp underlying_source(source) do
    @underlying_sources
    |> Enum.map(&Map.get(source, &1))
    |> Enum.reject(&is_nil/1)
    |> List.first
  end
end
