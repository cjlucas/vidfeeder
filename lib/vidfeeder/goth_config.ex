defmodule VidFeeder.GothConfig do
  use Goth.Config

  def init(config) do
    {:ok, Keyword.put(config, :json, decrypt_credentials!())}
  end

  def decrypt_credentials! do
    Application.app_dir(:vidfeeder, "priv/credentials")
    |> Path.join("vidfeeder_service_account_credentials")
    |> File.read!()
    |> Cipher.decrypt()
  end
end
