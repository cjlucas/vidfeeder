defmodule VidFeederWeb.API.SessionView do
  use VidFeederWeb, :view

  def render("show.json", %{user: user}) do
    %{
      session: %{
        user_id: user.id,
        access_token: user.access_token
      }
    }
  end
end
