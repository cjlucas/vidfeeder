defmodule VidFeeder.Repo.Migrations.AddSourceIdToSubscriptions do
  use Ecto.Migration

  alias VidFeeder.{Repo, Source, Subscription, User}

  import Ecto.Query

  def up do
    drop_if_exists table(:subscriptions)
    
    create table(:subscriptions) do
      add :title, :string
      add :user_id, references(:users), null: false
      add :source_id, references(:sources), null: false

      timestamps(type: :utc_datetime)
    end
  end

  def down do
  end
end
