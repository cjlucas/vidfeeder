defmodule YouTube.Channel do
  defstruct [:id, :title, :description, :image_url, :related_playlists]

  alias GoogleApi.YouTube.V3.Api

  alias YouTube.Playlist

  def info(conn, id) do
    {:ok, resp} = Api.Channels.youtube_channels_list(conn, "snippet,contentDetails", id: id)

    case resp.items do
      [] ->
        nil

      [channel] ->
        %__MODULE__{
          id: id,
          title: channel.snippet.title,
          description: channel.snippet.description,
          image_url: image_url(channel),
          related_playlists: %{
            uploads: channel.contentDetails.relatedPlaylists.uploads
          }
        }
    end
  end

  def uploads(conn, id) do
    {:ok, resp} = Api.Channels.youtube_channels_list(conn, "contentDetails", id: id)

    playlist_id =
      resp.items
      |> Enum.map(fn channel -> channel.contentDetails.relatedPlaylists.uploads end)
      |> List.first()

    Playlist.videos(conn, playlist_id)
  end

  defp image_url(channel) do
    sizes = [:maxres, :high, :medium, :standard, :default]

    Enum.find_value(sizes, fn size ->
      case Map.get(channel.snippet.thumbnails, size) do
        nil -> false
        image -> image.url
      end
    end)
  end
end
