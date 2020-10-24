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
  YoutubeDlSource,
  SourceImporter
}

user =
  %User{}
  |> User.create_changeset(%{
    password: "password",
    password_confirmation: "password",
    identifier_type: "email",
    identifier: "chris@cjl.io"
  })
  |> Repo.insert!()

source1 =
  %YoutubeDlSource{
    url: "https://www.youtube.com/watch?v=IAkoWbUcquA"
  }
  |> Source.build()
  |> Repo.insert!()

SourceImporter.run(source1)
SourceImporter.run(source1)

source2 =
  %YoutubeDlSource{
    url: "https://www.youtube.com/channel/UCXCZOhRINu9QPEgi7NBe8Ug"
  }
  |> Source.build()
  |> Repo.insert!()

SourceImporter.run(source2)
