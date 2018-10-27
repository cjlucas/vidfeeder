defmodule VidFeeder.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :binary, null: false
      add :access_token, :binary, null: false
    end
  end
end
