defmodule VidFeederWeb.Router do
  use VidFeederWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug VidFeederWeb.LoadCurrentUser
  end

  scope "/", VidFeederWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", VidFeederWeb.API do
    pipe_through :api

    post "/sessions", SessionController, :create

    post "/subscriptions", SubscriptionController, :create

    post "/users", UserController, :create
    get "/users/:id", UserController, :show

    get "/users/:id/subscriptions", UserSubscriptionsController, :index
  end

  get "/rss/:id", VidFeederWeb.FeedController, :rss
end
