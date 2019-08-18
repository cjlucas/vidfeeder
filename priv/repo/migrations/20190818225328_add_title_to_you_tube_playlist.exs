defmodule VidFeeder.Repo.Migrations.AddTitleToYouTubePlaylist do
  use Ecto.Migration

  import Ecto.Query

  alias VidFeeder.{
    Repo,
    YouTubePlaylist
  }

  def up do
    alter table(:youtube_playlists) do
      add :title, :string
      add :description, :string
      add :image_url, :string
    end

    flush()

    Repo.transaction(fn ->
      (from p in YouTubePlaylist)
      |> Repo.stream
      |> Enum.each(fn playlist ->
        playlist
        |> YouTubePlaylist.changeset(%{etag: nil})
        |> Repo.update!
      end)
    end)
  end

  def down do
    alter table(:youtube_playlists) do
      remove :title
      remove :description
      remove :image_url
    end
  end
end
