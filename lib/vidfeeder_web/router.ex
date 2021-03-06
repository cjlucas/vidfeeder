defmodule VidFeederWeb.Router do
  use VidFeederWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(VidFeederWeb.LoadCurrentUser)
  end

  scope "/api", VidFeederWeb.API do
    pipe_through(:api)

    post("/email_notifications", EmailNotificationController, :create)

    post("/sessions", SessionController, :create)

    post("/subscriptions", SubscriptionController, :create)

    post("/users", UserController, :create)
    get("/users/:id", UserController, :show)

    get("/users/:id/subscriptions", UserSubscriptionsController, :index)

    post("/feeds", FeedController, :create)
    get("/feeds/:id", FeedController, :show)
  end

  get("/rss/:id", VidFeederWeb.RssController, :show)

  scope "/", VidFeederWeb do
    # Use the default browser stack
    pipe_through(:browser)

    match(:*, "/*path", PageController, :index)
  end
end
