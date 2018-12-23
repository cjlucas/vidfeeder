defmodule VidFeeder.FeedProcessedMailer do
  alias SendGrid.Email

  def send(recipient, feed) do
    Email.build()
    |> Email.add_to(recipient)
    |> Email.put_from("notifications@vidfeeder2.cjlucas.net")
    |> Email.put_subject("Your feed is ready!")
    |> Email.put_phoenix_view(VidFeederWeb.EmailView)
    |> Email.put_phoenix_template("feed_processed.html", feed: feed)
    |> SendGrid.Mail.send
  end
end
