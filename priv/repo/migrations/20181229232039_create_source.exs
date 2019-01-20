defmodule VidFeeder.Repo.Migrations.CreateSource do
  use Ecto.Migration

  def change do
    create table(:youtube_playlists) do
      add :playlist_id, :string
      add :etag, :string

      timestamps()
    end

    create unique_index(:youtube_playlists, :playlist_id)

    create table(:youtube_videos) do
      add :video_id, :string
      add :title, :string
      add :description, :text
      add :duration, :integer
      add :published_at, :utc_datetime

      timestamps()
    end

    create unique_index(:youtube_videos, :video_id)

    create table(:youtube_playlist_items) do
      add :playlist_item_id, :string
      add :position, :integer
      add :published_at, :utc_datetime

      add :playlist_id, references(:youtube_playlists)
      add :video_id, references(:youtube_videos)

      timestamps()
    end

    create unique_index(:youtube_playlist_items, :playlist_item_id)

    create table(:youtube_channels) do
      add :channel_id, :string
      add :title, :string
      add :description, :text
      add :image_url, :string

      add :uploads_playlist_id, references(:youtube_playlists)

      timestamps()
    end

    create unique_index(:youtube_channels, :channel_id)

    create table(:youtube_users) do
      add :username, :string

      add :channel_id, references(:youtube_channels)

      timestamps()
    end

    create unique_index(:youtube_users, :username)
    
    create table(:sources) do
      add :state, :string
      add :last_refreshed_at, :utc_datetime

      add :youtube_playlist_id, references(:youtube_playlists)
      add :youtube_channel_id, references(:youtube_channels)
      add :youtube_user_id, references(:youtube_users)

      timestamps()
    end
  end
end
