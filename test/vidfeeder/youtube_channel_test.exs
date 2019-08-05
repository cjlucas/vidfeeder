defmodule VidFeeder.YouTubeChannelTest do
  use ExUnit.Case, async: true

  alias VidFeeder.{
    Repo,
    YouTubeChannel
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "create_changeset/1" do
    test "unique channel id" do
      assert "foo" ==
               YouTubeChannel.create_changeset("foo") |> Repo.insert!() |> Map.get(:channel_id)
    end

    test "unique constraint error" do
      cs = YouTubeChannel.create_changeset("foo")
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

  describe "api_changeset/2" do
    test "it" do
      channel = Repo.insert!(%YouTubeChannel{channel_id: "foo"})

      cs =
        YouTubeChannel.api_changeset(channel, %YouTube.Channel{
          title: "SBNation",
          description: "Uploads for SBNation",
          image_url: "http://youtube.com/path/to/image.jpg"
        })

      channel = Repo.update!(cs)
      assert "SBNation" == channel.title
      assert "Uploads for SBNation" == channel.description
      assert "http://youtube.com/path/to/image.jpg" == channel.image_url
    end
  end
end
