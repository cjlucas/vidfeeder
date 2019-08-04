defmodule VidFeederWeb.API.UserSubscriptionsController do
  use VidFeederWeb, :controller

  plug(VidFeederWeb.LoadUser)
  plug(VidFeederWeb.AuthorizeCurrentUser, resource: "user")

  alias VidFeeder.Repo

  def index(conn, %{"user" => user}) do
    user = Repo.preload(user, :subscriptions)

    render(conn, "index.json", subscriptions: user.subscriptions)
  end
end
