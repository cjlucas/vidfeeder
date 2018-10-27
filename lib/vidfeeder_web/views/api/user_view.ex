defmodule VidFeederWeb.API.UserView do
  use VidFeederWeb, :view

  @exposed_attributes [
    :id,
    :email,
    :access_token,
    :inserted_at,
    :updated_at
  ]

  def render("show.json", %{user: user}) do
    user = Map.take(user, @exposed_attributes)

    %{data: %{user: user}}
  end
end
