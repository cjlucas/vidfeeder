defmodule VidFeeder.Repo.Migrations.CreateSourceFromFeeds do
  use Ecto.Migration

  import Ecto.Query

  alias VidFeeder.{
    Repo,
    Feed,
    Source,
    YouTubeUser,
    YouTubeChannel,
    YouTubePlaylist
  }

  def up do
    Repo.transaction(fn ->
      (from f in Feed)
      |> Repo.stream
      |> Enum.reject(fn %{id: id} -> Repo.get(Source, id) != nil end)
      |> Enum.each(fn %{id: id, source_type: type, source_id: source_id} ->
        underlying_source_changeset =
          case type do
            "user" ->
              case Repo.get_by(YouTubeUser, username: source_id) do
                nil ->
                  YouTubeUser.create_changeset(source_id)
                _ ->
                  nil
              end
            "channel" ->
              case Repo.get_by(YouTubeChannel, channel_id: source_id) do
                nil ->
                  YouTubeChannel.create_changeset(source_id)
                _ ->
                  nil
              end

            "playlist" ->
              case Repo.get_by(YouTubePlaylist, playlist_id: source_id) do
                nil ->
                  YouTubePlaylist.create_changeset(source_id)
                _ ->
                  nil
              end
          end

          if underlying_source_changeset != nil do
            case Repo.insert(underlying_source_changeset) do
              {:ok, underlying_source} ->
                underlying_source
                |> Source.build
                |> Map.put(:id, id)
                |> Repo.insert

              {:error, err} ->
                IO.inspect err, label: "err"
            end
          end
      end)
    end)
  end

  def down do
  end
end
