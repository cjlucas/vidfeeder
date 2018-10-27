defmodule VidFeederWeb.API.UserSubscriptionsView do
  use VidFeederWeb, :view
  
  @exposed_attributes [
    :id,
    :title,
    :feed_id,
    :user_id,
    :inserted_at,
    :updated_at,
  ]

  def render("index.json", %{subscriptions: subscriptions}) do
    %{data: render_many(subscriptions, __MODULE__, "show.json", as: :subscription)}
  end

  def render("show.json", %{subscription: subscription}) do
    %{subscription: Map.take(subscription, @exposed_attributes)}
  end
end
