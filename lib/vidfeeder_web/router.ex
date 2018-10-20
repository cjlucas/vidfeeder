defmodule VidFeederWeb.Router do
  use VidFeederWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", VidFeederWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", VidFeederWeb.API do
    post "/subscriptions", SubscriptionController, :create
  end

  get "/rss/:id", VidFeederWeb.FeedController, :rss
end
