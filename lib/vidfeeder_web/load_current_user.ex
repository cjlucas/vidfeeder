defmodule VidFeederWeb.LoadCurrentUser do
  import Plug.Conn

  alias VidFeeder.{
    Repo,
    User
  }

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case conn.private[:auth_token] do
      %{user_id: user_id} ->
        user = Repo.get(User, user_id)
        params = Map.put(conn.params, "current_user", user)

        %{conn | params: params}
      nil ->
        conn
    end
  end
end
