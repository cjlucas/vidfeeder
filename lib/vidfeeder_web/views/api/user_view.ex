defmodule VidFeederWeb.API.SubscriptionView do
  use VidFeederWeb, :view

  @exposed_attributes [
    :id,
    :title,
    :feed_id,
    :user_id,
    :inserted_at,
    :updated_at,
  ]

  def render("show.json", %{subscription: subscription}) do
    subscription = Map.take(subscription, @exposed_attributes)

    %{subscription: subscription}
  end
end
