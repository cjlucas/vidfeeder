defmodule VidFeeder.Repo.Migrations.CreateVidfeederYoutubeDlSources do
  use Ecto.Migration

  def change do
    create table(:youtube_dl_sources) do
      add(:url, :string)

      timestamps()
    end
  end
end
