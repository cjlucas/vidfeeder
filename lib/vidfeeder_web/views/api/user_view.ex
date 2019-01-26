defmodule VidFeederWeb.API.UserView do
  use VidFeederWeb, :view

  @exposed_attributes [
    :id,
    :identifier_type,
    :identifier,
    :access_token,
    :inserted_at,
    :updated_at
  ]

  def render("show.json", %{user: user}) do
    user = Map.take(user, @exposed_attributes)

    %{data: %{user: user}}
  end
end
