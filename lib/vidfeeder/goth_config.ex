defmodule VidFeeder.GothConfig do
  use Goth.Config

  def init(config) do
    {:ok, Keyword.put(config, :json, decrypt_credentials!())}
  end

  def decrypt_credentials! do
    "config/creds/vidfeeder_service_account_credentials"
    |> File.read!
    |> Cipher.decrypt
  end
end
