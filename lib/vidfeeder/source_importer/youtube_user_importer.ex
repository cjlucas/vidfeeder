defmodule VidFeeder.SourceImporter.YouTubeUserImporter do
  alias VidFeeder.{
    YouTubeChannel,
    YouTubeUser,
    Repo
  }

  alias VidFeeder.SourceImporter.YouTubeChannelImporter

  def run(youtube_user) do
    youtube_user = Repo.preload(youtube_user, :channel)

    case youtube_user.channel do
      nil ->
        youtube_channel = create_youtube_channel(youtube_user)
        YouTubeChannelImporter.run(youtube_channel)

      youtube_channel ->
        YouTubeChannelImporter.run(youtube_channel)
    end
  end

  defp create_youtube_channel(youtube_user) do
    conn = YouTube.Connection.new
    user = YouTube.User.info(conn, youtube_user.username)

    channel_changeset =
      youtube_user
      |> Ecto.build_assoc(:channel, channel_id: user.channel.id)
      |> YouTubeChannel.api_changeset(user.channel)

    youtube_user
    |> YouTubeUser.user_channel_changeset(channel_changeset)
    |> Repo.update!
    |> Map.get(:channel)
  end
end
