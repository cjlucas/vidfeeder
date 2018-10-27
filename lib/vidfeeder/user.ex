defmodule VidFeeder.User do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :binary, virtual: true
    field :password_confirmation, :binary, virtual: true
    field :password_hash, :binary
    field :access_token, :binary

    has_many :subscriptions, VidFeeder.Subscription

    timestamps()
  end

  def password_matches?(user, password) do
    case Comeonin.Argon2.check_pass(user, password) do
      {:ok, _}    -> true
      {:error, _} -> false
    end
  end

  ## Changeset

  def create_changeset(user, params \\ %{}) do
    user
    |> changeset(params)
    |> validate_password(required: true)
    |> put_hashed_password
    |> generate_access_token
  end
  
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :password])
  end

  ## Changeset Helpers

  def validate_password(changeset, opts \\ []) do
    required = Keyword.get(opts, :required, false)
    validate_confirmation(changeset, :password, message: "does not match password", required: required)
  end

  def put_hashed_password(changeset) do
    password_hash = Comeonin.Argon2.add_hash(changeset.changes[:password])
    change(changeset, password_hash)
  end

  def generate_access_token(changeset) do
    access_token = 32 |> :crypto.strong_rand_bytes |> Base.encode16(case: :lower)
    put_change(changeset, :access_token, access_token)
  end
end
