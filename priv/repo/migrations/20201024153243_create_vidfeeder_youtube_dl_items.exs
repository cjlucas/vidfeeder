defmodule VidFeeder.Repo.Migrations.CreateVidfeederYoutubeDlItems do
  use Ecto.Migration

  def change do
    create table(:vidfeeder_youtube_dl_items) do
      add(:youtube_dl_id, :string)
      add(:title, :string)
      add(:description, :string)
      add(:duration, :integer)
      add(:image_url, :string)
      add(:published_at, :naive_datetime)

      add(:youtube_dl_source_id, references(:vidfeeder_youtube_dl_sources), null: false)

      timestamps()
    end
  end
end
