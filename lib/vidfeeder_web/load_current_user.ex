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
    case bearer_token(conn) do
      token when is_binary(token) ->
        user = Repo.get_by(User, access_token: token)
        params = Map.put(conn.params, "current_user", user)

        %{conn | params: params}
      nil ->
        conn
    end
  end

  defp bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      [header | _] ->
        header |> String.split(" ") |> List.last
      _ ->
        nil
    end
  end
end
