defmodule VidFeeder.GothConfig do
  use Goth.Config

  def init(config) do
    {:ok, Keyword.put(config, :json, credentials())}
  end

  def credentials do
    System.fetch_env!("GOOGLE_APPLICATION_CREDENTIALS") |> Base.decode64!
  end
end
