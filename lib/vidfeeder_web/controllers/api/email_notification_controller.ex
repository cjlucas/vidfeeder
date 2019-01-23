defmodule VidFeederWeb.API.EmailNotificationController do
  use VidFeederWeb, :controller

  alias VidFeeder.{
    Feed,
    Repo
  }

  def create(conn, params) do
    %{"email" => email, "feed_id" => feed_id} = params

    case Repo.get(Feed, feed_id) do
      nil ->
        send_resp(conn, :not_found, "")
      feed ->
        :ok = VidFeeder.FeedImportNotificationManager.notify_user(email, feed)
        send_resp(conn, :ok, "")
    end
  end
end
