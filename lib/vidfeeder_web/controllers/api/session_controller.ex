defmodule VidFeederWeb.API.SessionController do
  use VidFeederWeb, :controller

  plug VidFeederWeb.LoadUser

  alias VidFeeder.{
    Repo,
    User
  }

  def create(conn, params) do
    %{"email" => email, "password" => password} = params

    case Repo.get_by(User, identifier_type: "email", identifier: email) do
      nil ->
        resp(conn, :not_found, "")
      user ->
        if User.password_matches?(user, password) do
          render conn, "show.json", user: user
        else
          resp(conn, :unauthorized, "")
        end
    end
  end
end
