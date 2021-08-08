defmodule VidFeeder.Repo.Migrations.AddUniqueCompoundIndexToYoutubePlaylistItems do
  use Ecto.Migration

  def change do
    create(unique_index(:youtube_playlist_items, [:playlist_item_id, :video_id]))
  end
end
