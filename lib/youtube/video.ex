defmodule YouTube.Video do
  defstruct [
    :id,
    :title,
    :description,
    :published_at,
    :duration,
    :image_url,
    :region_restricted,
    :allowed_countries,
    :blocked_countries
  ]

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
        image_url: image_url(item),
        region_restricted: region_restricted?(item.contentDetails),
        allowed_countries: allowed_countries(item),
        blocked_countries: blocked_countries(item)
      }
    end)
  end

  def image_url(item) do
    case item.snippet.thumbnails.maxres do
      nil   -> nil
      image -> image.url
    end
  end

  def region_restricted?(%{regionRestriction: regionRestriction}) when is_nil(regionRestriction), do: false
  def region_restricted?(%{regionRestriction: regionRestriction}) do
      !(is_nil(regionRestriction.allowed) && is_nil(regionRestriction.blocked))
  end

  def allowed_countries(%{contentDetails: contentDetails}) do
    contentDetails
    |> get(:regionRestriction, %{})
    |> get(:allowed, [])
  end

  def blocked_countries(%{contentDetails: contentDetails}) do
    contentDetails
    |> get(:regionRestriction, %{})
    |> get(:blocked, [])
  end

  defp get(map, key, nil_fallback) do
    case Map.get(map, key) do
      nil -> nil_fallback
      value -> value
    end
  end
end
