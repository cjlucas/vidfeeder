defmodule VidFeeder.SourceImporter.YouTubeUserImporter do
  use Log

  alias VidFeeder.{
    YouTubeChannel,
    YouTubeUser,
    Repo
  }

  alias VidFeeder.SourceImporter.YouTubeChannelImporter

  def run(youtube_user) do
    Log.add_context([youtube_uesr: youtube_user.id], fn ->
      import_youtube_user(youtube_user)
    end)
  end

  defp create_youtube_channel(youtube_user) do
    conn = YouTube.Connection.new
    user = YouTube.User.info(conn, youtube_user.username)

    channel_or_channel_changeset =
      case Repo.get_by(YouTubeChannel, channel_id: user.channel.id) do
        nil ->
          Log.info("Could not find YouTubeChannel with channel ID, will create",
            channel_id: user.channel.id)

          YouTubeChannel.create_changeset(user.channel.id)
          |> Repo.insert!
          |> YouTubeChannel.api_changeset(user.channel)
          |> Repo.update!

        youtube_channel ->
          Log.info("Found YouTubeChannel with channel ID, will associate with user",
            channel_id: user.channel.id)

          youtube_channel
      end

    youtube_user
    |> YouTubeUser.user_channel_changeset(channel_or_channel_changeset)
    |> Repo.update!
    |> Map.get(:channel)
  end

  defp import_youtube_user(youtube_user) do
    youtube_user = Repo.preload(youtube_user, :channel)

    case youtube_user.channel do
      nil ->
        Log.info("Channel not associated with user, will find/create")
        youtube_channel = create_youtube_channel(youtube_user)
        import_user_channel(youtube_channel)

      youtube_channel ->
        import_user_channel(youtube_channel)
    end
  end

  defp import_user_channel(youtube_channel) do
    Log.info("Importing user channel", channel_id: youtube_channel.id)
    YouTubeChannelImporter.run(youtube_channel)
  end
end
