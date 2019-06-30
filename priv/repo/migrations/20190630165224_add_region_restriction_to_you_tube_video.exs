defmodule VidFeeder.Repo.Migrations.AddRegionRestrictionToYouTubeVideo do
  use Ecto.Migration

  def change do
    alter table(:youtube_videos) do
      add :region_restricted, :boolean, default: false
      add :allowed_countries, {:array, :string}, default: []
      add :blocked_countries, {:array, :string}, default: []
    end
  end
end
