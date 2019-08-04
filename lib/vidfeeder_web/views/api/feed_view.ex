defmodule VidFeederWeb.API.FeedView do
  use VidFeederWeb, :view

  @exposed_attributes [
    :id,
    :title,
    :description,
    :image_url
  ]

  def render("show.json", %{feed: feed}) do
    feed = Map.take(feed, feed_attributes(feed))

    %{data: %{feed: feed}}
  end

  defp feed_attributes(feed) do
    # If a feed hasn't been imported, expose only id and state
    if feed.title != nil do
      @exposed_attributes
    else
      [:id, :state]
    end
  end
end
