defmodule VidFeederWeb.API.SessionView do
  use VidFeederWeb, :view

  def render("show.json", %{user: user}) do
    {:ok, token, expires_at} = VidFeeder.AuthToken.create_and_sign(user.id)
    expires_in_seconds = DateTime.diff(expires_at, DateTime.utc_now)

    %{
      session: %{
        access_token: token,
        expires_in: expires_in_seconds
      }
    }
  end
end
