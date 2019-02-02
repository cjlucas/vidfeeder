defmodule VidFeeder.Subscription do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "subscriptions" do
    field :title, :string

    belongs_to :user, VidFeeder.User
    belongs_to :source, VidFeeder.Source

    timestamps()
  end

  def create_changeset(user, source) do
    %__MODULE__{}
    |> change
    |> put_assoc(:user, user)
    |> put_assoc(:source, source)
  end

  def changeset(subscription, params \\ %{}) do
    subscription
    |> cast(params, [:title])
  end
end
