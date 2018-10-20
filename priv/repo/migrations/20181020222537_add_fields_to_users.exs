defmodule VidFeeder.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :binary

      add :access_token, :binary
      add :access_token_hash, :binary
    end
  end
end
