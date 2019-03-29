defmodule VidFeeder.YouTubeVideoMetadataWorker do
  use GenStage

  alias VidFeeder.{
    Repo,
    YouTubeVideo
  }

  require Logger

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    subscribe_to_opts = [{VidFeeder.YouTubeVideoMetadataManager, max_demand: 10}]
    {:consumer, nil, subscribe_to: subscribe_to_opts}
  end

  def handle_events(videos, _from, state) do
    Enum.each(videos, &fetch_video_metadata/1)
    {:noreply, [], state}
  end
  
  defp fetch_video_metadata(video) do
    video_url = "https://www.youtube.com/watch?v=#{video.video_id}"
    url = "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"

    case HTTPoison.head(url, [], follow_redirect: true, timeout: 20_000, recv_timeout: 20_000) do
      {:ok, %{status_code: 200} = resp} ->
        %{"Content-Type" => mime_type, "Content-Length" => size} = Enum.into(resp.headers, %{})

        video
        |> YouTubeVideo.changeset(%{
          mime_type: mime_type,
          size: size
        })
        |> Repo.update!

      {:ok, resp} ->
        Logger.debug("Unknown response: #{inspect resp}")

      {:error, error} ->
        Logger.debug("Error: #{inspect error}")
    end
  end
end
