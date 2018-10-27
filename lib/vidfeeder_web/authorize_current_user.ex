defmodule VidFeederWeb.AuthorizeCurrentUser do
  import Phoenix.Controller
  import Plug.Conn


  def init(opts) do
    opts
  end

  def call(conn, opts) do
    action = action_name(conn)
    current_user = Map.get(conn.params, "current_user")
    resource = Map.get(conn.params, opts[:resource])

    if Bodyguard.permit?(VidFeeder.Policy, action, current_user, resource) do
      conn
    else
      unauthorized!(conn)
    end
  end

  defp unauthorized!(conn) do
    conn
    |> send_resp(:unauthorized, "")
    |> halt
  end
end
