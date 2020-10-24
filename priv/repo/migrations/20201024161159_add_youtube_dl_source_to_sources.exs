defmodule VidFeeder.Repo.Migrations.AddYoutubeDlSourceToSources do
  use Ecto.Migration

  def change do
    alter table(:sources) do
      add(:youtube_dl_source_id, references(:vidfeeder_youtube_dl_sources))
    end
  end
end
