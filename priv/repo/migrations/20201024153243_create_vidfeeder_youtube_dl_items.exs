defmodule VidFeeder.Repo.Migrations.CreateVidfeederYoutubeDlItems do
  use Ecto.Migration

  def change do
    create table(:youtube_dl_items) do
      add(:youtube_dl_id, :string)
      add(:title, :string)
      add(:description, :text)
      add(:duration, :integer)
      add(:image_url, :string)
      add(:published_at, :utc_datetime)

      add(:youtube_dl_source_id, references(:youtube_dl_sources), null: false)

      timestamps()
    end

    create(unique_index(:youtube_dl_items, [:youtube_dl_source_id, :youtube_dl_id]))
  end
end
