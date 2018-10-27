defmodule VidFeederWeb.LoadUser do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(%{params: params} = conn, _opts) do
    case Map.get(params, "id") do
      nil ->
        conn
      id ->
        load_user(conn, id)
    end
  end

  defp load_user(conn, id) do
    %{params: params} = conn

    case VidFeeder.Repo.get(VidFeeder.User, id) do
      nil ->
        conn
        |> send_resp(:not_found, "")
        |> halt()
      user ->
        params = Map.put(params, "user", user)
        %{conn | params: params}
    end
  end
end
