defmodule VidFeederWeb.API.SessionController do
  use VidFeederWeb, :controller

  plug VidFeederWeb.LoadUser

  alias VidFeeder.{
    Repo,
    User
  }

  alias VidFeederWeb.BasicAuthHeaderParser

  def create(conn, _params) do
    case parse_auth_header(conn) do
      {:ok, {email, password}} ->
        case authorize_user(email, password) do
          {:ok, user} ->
            render(conn, "show.json", user: user)

          {:error, :not_found} ->
            resp(conn, :not_found, "")

          {:error, :bad_password} ->
            resp(conn, :unauthorized, "")
        end

      {:ok, nil} ->
        user = User.create_anonymous_user_changeset |> Repo.insert!
        render(conn, "show.json", user: user)

      :error ->
        resp(conn, :bad_request, "")
    end
  end

  defp authorize_user(email, password) do
    case Repo.get_by(User, identifier_type: "email", identifier: email) do
      nil ->
        {:error, :not_found}
      user ->
        user = Repo.preload(user, :login_credentials)

        if User.password_matches?(user, password) do
          {:ok, user}
        else
          {:error, :bad_password}
        end
    end
  end

  defp parse_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [] ->
        {:ok, nil}

      ["Basic " <> payload | _] ->
        {email, password} =
          payload
          |> String.trim
          |> Base.decode64!
          |> String.split(":", parts: 2)
          |> List.to_tuple

        {:ok, {email, password}}

      _ ->
        :error
    end
  end
end
