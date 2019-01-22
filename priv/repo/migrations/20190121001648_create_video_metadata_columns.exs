defmodule VidFeeder.Repo.Migrations.CreateVideoMetadataColumns do
  use Ecto.Migration

  def change do
    alter table(:youtube_videos) do
      add(:mime_type, :string)
      add(:size, :bigint)
    end
  end
end
