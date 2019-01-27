defmodule VidFeeder.LoginCredentials do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "login_credentials" do
    field :password, :binary, virtual: true
    field :password_hash, :binary

    belongs_to :user, VidFeeder.User

    timestamps(type: :utc_datetime)
  end

  def changeset(login_credentials, params \\ %{}) do
    login_credentials
    |> cast(params, [:password])
    |> put_hashed_password_if_necessary
  end
  
  defp put_hashed_password_if_necessary(changeset) do
    case fetch_change(changeset, :password) do
      {:ok, password} ->
        password_hash = Comeonin.Argon2.add_hash(password)
        change(changeset, password_hash)
      :error ->
        changeset
    end
  end
end
