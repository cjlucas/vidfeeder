defmodule VidFeeder.Subscription do
  use VidFeeder.Schema

  import Ecto.Changeset

  @required_fields [:feed_id, :user_id]

  schema "subscriptions" do
    field(:title, :string)

    belongs_to(:user, VidFeeder.User)
    belongs_to(:feed, VidFeeder.Feed)

    timestamps()
  end

  def changeset(subscription, params \\ %{}) do
    subscription
    |> cast(params, [:title] ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
