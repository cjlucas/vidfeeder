defmodule YouTube.Playlist do
  defstruct [:id, :etag, :title, :description, :image_url]

  alias GoogleApi.YouTube.V3.Api
  
  def info(conn, id) do
    {:ok, resp} = Api.Playlists.youtube_playlists_list(conn, "snippet", id: id)

    case resp.items do
      [] ->
        nil
      [playlist] ->
        %__MODULE__{
          id: id,
          etag: playlist.etag,
          title: playlist.snippet.title,
          description: playlist.snippet.description,
          image_url: image_url(playlist)
        }
    end

  end

  def items(conn, id) do
    request(conn, id)
    |> YouTube.Paginator.paginate
    |> Enum.flat_map(fn resp -> resp.items end)
    |> Enum.map(fn item ->
      %YouTube.PlaylistItem{
        id: item.id,
        video_id: item.contentDetails.videoId,
        title: item.snippet.title,
        description: item.snippet.description,
        position: item.snippet.position,
        published_at: item.snippet.publishedAt
      }
    end)
  end

  def videos(conn, id) do
    video_ids =
      conn
      |> items(id)
      |> Enum.map(&Map.get(&1, :video_id))
      |> IO.inspect

    YouTube.Video.get(conn, video_ids)
  end

  defp request(conn, id) do
    fn page_token ->
      Api.PlaylistItems.youtube_playlist_items_list(
        conn, 
        "id,contentDetails,snippet", 
        playlistId: id,
        pageToken: page_token,
        maxResults: 50
      )
    end
  end
  
  defp image_url(playlist) do
    sizes = [:maxres, :high, :medium, :standard, :default]

    Enum.find_value(sizes, fn size ->
      case Map.get(playlist.snippet.thumbnails, size) do
        nil -> false
        image -> image.url
      end
    end)
  end
end
