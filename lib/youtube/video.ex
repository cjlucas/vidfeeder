defmodule YouTube.Video do
  defstruct [:id, :title, :description, :published_at, :duration, :image_url]

  alias GoogleApi.YouTube.V3.Api

  def get(conn, ids) do
    ids
    |> Enum.chunk_every(50)
    |> Enum.map(fn chunk ->
      video_ids = Enum.join(chunk, ",")
      {:ok, resp} = Api.Videos.youtube_videos_list(conn, "id,contentDetails,snippet", id: video_ids, maxResults: 50)
      resp
    end)
    |> Enum.flat_map(&Map.get(&1, :items))
    |> Enum.map(fn item ->
      %__MODULE__{
        id: item.id,
        title: item.snippet.title,
        description: item.snippet.description,
        published_at: item.snippet.publishedAt,
        duration: Timex.Parse.Duration.Parser.parse!(item.contentDetails.duration).seconds,
        image_url: image_url(item)
      }
    end)
  end

  def image_url(item) do
    case item.snippet.thumbnails.maxres do
      nil   -> nil
      image -> image.url
    end
  end
end
