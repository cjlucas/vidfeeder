defmodule VidFeederWeb.API.SubscriptionController do
  use VidFeederWeb, :controller

  alias VidFeeder.{
    Feed,
    ImportFeedWorker,
    Repo,
    Subscription,
    User
  }

  def create(conn, params) do
    user = Map.get(params, "current_user")

    params = Map.merge(params, %{"user_id" => user.id})

    subscription =
      %Subscription{}
      |> Subscription.changeset(params)
      |> Repo.insert!

    render conn, "show.json", subscription: subscription
  end
end
