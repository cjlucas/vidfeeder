defmodule VidFeeder.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    ## Users
    create table(:users) do
      add :email, :string

      timestamps()
    end

    create unique_index(:users, :email)

    ## Feeds
    create table(:feeds) do
      add :source, :string
      add :source_type, :string
      add :source_id, :string
      add :title, :string
      add :description, :text
      add :image_url, :string
      add :state, :string
      add :last_refreshed_at, :utc_datetime

      timestamps()
    end

    create unique_index(:feeds, [:source, :source_type, :source_id])

    ## Items
    create table(:items) do
      add :title, :string
      add :description, :text
      add :source_id, :string
      add :duration, :integer
      add :image_url, :string
      add :size, :string
      add :mime_type, :string
      add :published_at, :utc_datetime, usec: false

      timestamps()
    end

    ## Feeds Items Join Table
    create table(:feeds_items, primary_key: false) do
      add :feed_id, references(:feeds), null: false
      add :item_id, references(:items), null: false
    end

    create unique_index(:feeds_items, [:feed_id, :item_id])
    
    ## Subscriptions
    create table(:subscriptions) do
      add :title, :string
      add :source, :string
      add :resource_type, :string
      add :resource_id, :string

      add :user_id, references(:users), null: false
      add :feed_id, references(:feeds), null: false

      timestamps()
    end
  end
end
