# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VidFeeder.Repo.insert!(%VidFeeder.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias VidFeeder.{
  Repo,
  User,
  Feed,
  Subscription,
  FeedProcessor
}

user = Repo.insert!(%User{
  email: "chris@cjl.io"
})

feed1 = Repo.insert!(%Feed{
  source: "youtube",
  source_type: "channel",
  source_id: "UCWZTdLbltJBTlXvpzTjbszA"
})

feed2 = Repo.insert!(%Feed{
  source: "youtube",
  source_type: "user",
  source_id: "TrumpSC"
})

feed3 = Repo.insert!(%Feed{
  source: "youtube",
  source_type: "playlist",
  source_id: "PLaDrN74SfdT5xZKh7TsCL4ydk7TOduLeu"
})

Repo.insert!(%Subscription{
  user_id: user.id,
  feed_id: feed1.id,
  title: "Omnislash"
})

Repo.insert!(%Subscription{
  user_id: user.id,
  feed_id: feed2.id,
  title: "TrumpSC's Uploads"
})

Repo.insert!(%Subscription{
  user_id: user.id,
  feed_id: feed3.id,
  title: "Awful Squad"
})

FeedProcessor.run(feed3)
FeedProcessor.run(feed1)
FeedProcessor.run(feed2)
