defmodule VidFeeder.Repo.Migrations.AddUserIdentifierConstraints do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify(:identifier_type, :string, null: false)
      modify(:identifier, :string, null: false)
    end

    create unique_index(:users, [:identifier, :identifier_type])
  end
end
