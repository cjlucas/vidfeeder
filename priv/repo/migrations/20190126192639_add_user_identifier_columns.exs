defmodule VidFeeder.Repo.Migrations.AddUserIdentifierColumns do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :identifier_type, :string
      add :identifier, :string
    end
  end
end
