defmodule VidFeeder.User do
  use VidFeeder.Schema

  import Ecto.Changeset

  @valid_identiifer_types ["email"]

  schema "users" do
    field(:identifier_type, :string)
    field(:identifier, :string)
    field(:password, :binary, virtual: true)
    field(:password_confirmation, :binary, virtual: true)
    field(:password_hash, :binary)
    field(:access_token, :binary)

    has_one(:login_credentials, VidFeeder.LoginCredentials, on_replace: :update)
    has_many(:subscriptions, VidFeeder.Subscription)

    timestamps()
  end

  def password_matches?(user, password) do
    case Comeonin.Argon2.check_pass(user.login_credentials, password) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  ## Changeset

  def create_changeset(user, params \\ %{}) do
    user
    |> changeset(params)
    |> validate_password(required: true)
    |> generate_access_token
  end

  def changeset(user, params \\ %{}) do
    params = prepare_params(params)

    user
    |> cast(params, [:identifier_type, :identifier, :password])
    |> cast_assoc(:login_credentials)
    |> validate_inclusion(:identifier_type, @valid_identiifer_types)
    |> validate_required([:identifier_type, :identifier])
    |> unique_constraint(:identifier, name: :users_identifier_identifier_type_index)
  end

  defp prepare_params(params) do
    case params["password"] do
      nil ->
        params

      password ->
        Map.put(params, "login_credentials", %{"password" => password})
    end
  end

  ## Changeset Helpers

  def validate_password(changeset, opts \\ []) do
    required = Keyword.get(opts, :required, false)

    validate_confirmation(changeset, :password,
      message: "does not match password",
      required: required
    )
  end

  def generate_access_token(changeset) do
    access_token = 32 |> :crypto.strong_rand_bytes() |> Base.encode16(case: :lower)
    put_change(changeset, :access_token, access_token)
  end
end
