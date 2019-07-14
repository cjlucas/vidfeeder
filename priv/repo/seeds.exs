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
  Source,
  YouTubePlaylist,
  YouTubeChannel,
  YouTubeUser,
  SourceImporter
}

user = 
  %User{}
  |> User.create_changeset(%{
    password: "password",
    password_confirmation: "password",
    identifier_type: "email",
    identifier: "chris@cjl.io",
  })
  |> Repo.insert!

source1 =
  %YouTubePlaylist{playlist_id: "PLyAkNLi4f70XsYSdNZxpWATH8Xy31Rh_v"}
  |> Source.build
  |> Repo.insert!

SourceImporter.run(source1)

source2 =
  %YouTubeChannel{channel_id: "UCMu3_s7WCRCJrbh37UKmJ-A"}
  |> Source.build
  |> Repo.insert!

SourceImporter.run(source2)

source3 =
  %YouTubeUser{username: "TrumpSC"}
  |> Source.build
  |> Repo.insert!

SourceImporter.run(source3)
