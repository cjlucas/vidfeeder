defmodule VidFeeder.YouTubeUserTest do
  use ExUnit.Case, async: false

  alias VidFeeder.{
    Repo,
    YouTubeUser,
    YouTubeChannel
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "create_changeset/1" do
    test "unique username" do
      assert "foo" ==
               YouTubeUser.create_changeset("foo") |> Repo.insert!() |> Map.get(:username)
    end

    test "unique constraint error" do
      cs = YouTubeUser.create_changeset("foo")
      Repo.insert!(cs)

      assert_raise(
        Ecto.InvalidChangesetError,
        ~r"could not perform insert because changeset is invalid",
        fn ->
          Repo.insert!(cs)
        end
      )
    end
  end

  describe "user_channel_changeset/2" do
    test "association works" do
      user = Repo.insert!(%YouTubeUser{username: "foo"}) |> Repo.preload(:channel)
      channel = Repo.insert!(%YouTubeChannel{channel_id: "bar"})

      user = YouTubeUser.user_channel_changeset(user, channel) |> Repo.update!()
      assert channel.id == user.channel_id
    end
  end
end
