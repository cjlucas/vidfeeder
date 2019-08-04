defmodule VidFeederWeb.API.EmailNotificationController do
  use VidFeederWeb, :controller

  alias VidFeeder.{
    Source,
    Repo
  }

  def create(conn, params) do
    %{"email" => email, "feed_id" => source_id} = params

    case Repo.get(Source, source_id) do
      nil ->
        send_resp(conn, :not_found, "")

      source ->
        :ok = VidFeeder.FeedImportNotificationManager.notify_user(email, source)
        send_resp(conn, :ok, "")
    end
  end
end
