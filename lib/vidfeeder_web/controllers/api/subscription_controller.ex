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
    feed =
      %Feed{}
      |> Feed.changeset(params)
      |> Feed.insert_or_get_existing!

    if is_nil(feed.last_refreshed_at) do
      ImportFeedWorker.import_feed(feed)
    end

    user = Map.get(params, "current_user")
    subscription =
      %Subscription{feed_id: feed.id, user_id: user.id} 
      |> Subscription.changeset(params)
      |> Repo.insert!

    render conn, "show.json", subscription: subscription
  end
end
