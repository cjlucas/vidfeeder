defmodule VidFeeder.Repo.Migrations.BackfillUserIdentifierColumns do
  use Ecto.Migration

  alias VidFeeder.{Repo, User}
  import Ecto.Query

  def up do
    Repo.transaction(fn ->
      (from u in User)
      |> Repo.stream
      |> Enum.each(fn user ->
        %{email: email} = user

        user
        |> User.changeset
        |> Ecto.Changeset.force_change(:identifier, email)
        |> Repo.update!
      end)
    end)
  end

  def down do
  end
end
