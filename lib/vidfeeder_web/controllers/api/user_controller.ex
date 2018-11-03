defmodule VidFeederWeb.API.UserController do
  use VidFeederWeb, :controller

  plug VidFeederWeb.LoadUser when action in [:show]
  plug VidFeederWeb.AuthorizeCurrentUser, [resource: "user"] when action in [:show]

  alias VidFeeder.{
    Repo,
    User
  }

  def create(conn, params) do
    user = %User{} |> User.create_changeset(params) |> Repo.insert!

    render conn, "show.json", user: user
  end

  def show(conn, %{"user" => user}) do
    render conn, "show.json", user: user
  end
end
