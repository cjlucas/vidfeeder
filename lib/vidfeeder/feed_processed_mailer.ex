defmodule VidFeeder.FeedProcessedMailer do
  alias SendGrid.Email

  def send(recipients, feed) do
    email =
      Email.build()
      |> Email.put_from("notifications@vidfeeder2.cjlucas.net", "VidFeeder")
      |> Email.put_subject("Your feed is ready!")
      |> Email.put_phoenix_view(VidFeederWeb.EmailView)
      |> Email.put_phoenix_template("feed_processed.html", feed: feed)

    email = 
      recipients
      |> List.wrap
      |> Enum.reduce(email, fn recipient, email -> Email.add_to(email, recipient) end)

    SendGrid.Mail.send(email)
  end
end
