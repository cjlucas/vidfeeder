defmodule VidFeeder.Repo.Migrations.MigrateLoginCredentials do
  use Ecto.Migration

  alias VidFeeder.{Repo, User, LoginCredentials}

  import Ecto.Query

  def up do
    Repo.transaction(fn ->
      (from u in User)
      |> Repo.stream
      |> Enum.each(fn user ->
        user = Repo.preload(user, :login_credentials)

        if user.login_credentials == nil do
          user
          |> Ecto.build_assoc(:login_credentials)
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.force_change(:password_hash, user.password_hash)
          |> Repo.insert!
        end
      end)
    end)
  end

  def down do
  end
end
