defmodule VidFeeder.Repo.Migrations.CreateVidfeederYoutubeDlSources do
  use Ecto.Migration

  def change do
    create table(:youtube_dl_sources) do
      add(:url, :string)

      timestamps()
    end

    create(unique_index(:youtube_dl_sources, :url))
  end
end
