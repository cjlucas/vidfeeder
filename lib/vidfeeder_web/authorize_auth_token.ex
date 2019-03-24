defmodule VidFeederWeb.ValidateAuthToken do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case bearer_token(conn) do
      {:ok, token} ->
        case VidFeeder.AuthToken.decode(token) do
          {:ok, auth_token} ->
            put_private(conn, :auth_token, auth_token)

          {:error, _} ->
            conn
            |> resp(:unauthorized, "invalid_token")
            |> halt
        end

      {:error, :not_found} ->
        conn
    end
  end


  defp bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] ->
        {:ok, String.trim(token)}

      _ ->
        {:error, :not_found}
    end
  end
end
