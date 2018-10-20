defmodule VidFeeder.Subscription do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "subscriptions" do
    field :title, :string

    belongs_to :user, VidFeeder.User
    belongs_to :feed, VidFeeder.Feed

    timestamps()
  end

  def changeset(subscription, params \\ %{}) do
    subscription
    |> cast(params, [:title])
  end
end
