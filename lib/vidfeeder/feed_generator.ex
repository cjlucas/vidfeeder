defmodule VidFeeder.FeedGenerator do
  alias VidFeeder.{
    Feed,
    Item,
    Repo,
    Source,
    YouTubeUser,
    YouTubeChannel,
    YouTubePlaylist,
    YoutubeDlSource,
    YoutubeDlItem
  }

  def generate(source) do
    source
    |> Source.underlying_source(Repo)
    |> do_generate
    |> inject_source_attributes(source)
  end

  defp do_generate(%YouTubeUser{} = user) do
    user = Repo.preload(user, :channel)

    if user.channel != nil do
      do_generate(user.channel)
    else
      %Feed{}
    end
  end

  defp do_generate(%YouTubeChannel{} = channel) do
    channel = Repo.preload(channel, :uploads_playlist)

    %Feed{
      title: channel.title,
      description: channel.description,
      image_url: channel.image_url,
      items: generate_items(channel.uploads_playlist)
    }
  end

  defp do_generate(%YouTubePlaylist{} = playlist) do
    %Feed{
      title: playlist.title || playlist.playlist_id,
      description: playlist.description,
      image_url: playlist.image_url,
      items: generate_items(playlist)
    }
  end

  defp do_generate(%YoutubeDlSource{} = youtube_dl_source) do
    items =
      youtube_dl_source
      |> Repo.preload(:items)
      |> Map.get(:items)
      |> Enum.map(fn item ->
        video_url = YoutubeDlItem.to_url(item)
        url = "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"

        %Item{
          guid: item.youtube_dl_id,
          title: item.title,
          description: item.description,
          duration: item.duration,
          url: url,
          published_at: item.inserted_at
        }
      end)

    %Feed{
      title: youtube_dl_source.url,
      items: items
    }
  end

  defp generate_items(playlist) when is_nil(playlist), do: []

  defp generate_items(playlist) do
    playlist = Repo.preload(playlist, items: :video)

    playlist.items
    |> Enum.sort_by(fn playlist_item -> playlist_item.position end)
    |> Enum.map(fn playlist_item ->
      video_url = "https://www.youtube.com/watch?v=#{playlist_item.video.video_id}"
      url = "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"

      %Item{
        guid: playlist_item.video.id,
        title: playlist_item.video.title,
        description: playlist_item.video.description,
        duration: playlist_item.video.duration,
        published_at: playlist_item.video.published_at,
        size: playlist_item.video.size,
        mime_type: playlist_item.video.mime_type,
        url: url
      }
    end)
  end

  defp inject_source_attributes(feed, source) do
    attributes = Map.take(source, [:id, :state])
    Map.merge(feed, attributes)
  end
end
