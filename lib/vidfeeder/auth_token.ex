defmodule VidFeeder.AuthToken do
  defstruct user_id: nil

  use Joken.Config

  def create_and_sign(user_id) do
    auth_token = %__MODULE__{user_id: user_id}
    claims = additional_claims(auth_token)

    case generate_and_sign(claims) do
      {:ok, bearer_token, %{"exp" => exp}} ->
        expires_at = DateTime.from_unix!(exp)
        {:ok, bearer_token, expires_at}

      {:error, _} ->
        :error
    end
  end

  def decode(signed_token) do
    case verify_and_validate(signed_token) do
      {:ok, claims} ->
        auth_token = %__MODULE__{user_id: claims["user_id"]}
        {:ok, auth_token}


      {:error, err} ->
        {:error, err}
    end
  end

  defp additional_claims(auth_token) do
    %{
      "user_id" => auth_token.user_id
    }
  end
end
