defmodule VidFeeder.Repo.Migrations.CreateLoginCredentials do
  use Ecto.Migration

  def change do
    create table(:login_credentials) do
      add :password_hash, :binary, null: false
      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
