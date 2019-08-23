defmodule VidFeeder.Repo.Migrations.UseTextForYoutubePlaylistDescription do
  use Ecto.Migration

  def change do
    alter table(:youtube_playlists) do
      remove :description
    end

    flush()

    alter table(:youtube_playlists) do
      add :description, :text
    end
  end
end
