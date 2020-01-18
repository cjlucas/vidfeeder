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

  def run(source) do
    Log.add_context([source_id: source.id], fn ->
      import_source(source)
    end)
  end

  defp import_source(source) do
    case Source.underlying_source(source, Repo) do
      %YouTubeUser{} = user ->
        YouTubeUserImporter.run(user)

      %YouTubeChannel{} = channel ->
        YouTubeChannelImporter.run(channel)

      %YouTubePlaylist{} = playlist ->
        YouTubePlaylistImporter.run(playlist)
    end

    source
    |> Source.changeset(%{state: "processed", last_refreshed_at: DateTime.utc_now()})
    |> Repo.update!()

    :ok
  end
end
