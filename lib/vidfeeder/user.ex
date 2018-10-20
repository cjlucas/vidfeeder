defmodule VidFeeder.User do
  use VidFeeder.Schema

  schema "users" do
    field :email, :string

    has_many :subscriptions, VidFeeder.Subscription

    timestamps()
  end
end
