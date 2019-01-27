defmodule VidFeeder.Repo.Migrations.ChangeUsersPasswordHashNullable do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :password_hash, :binary, null: true
    end
  end
  
  def down do
    alter table(:users) do
      modify :password_hash, :binary, null: false
    end
  end
end
