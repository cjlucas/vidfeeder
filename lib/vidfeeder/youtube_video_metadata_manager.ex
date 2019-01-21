defmodule VidFeeder.YouTubeVideoMetadataManager do
  use GenStage

  ## Client

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def process_video(video) do
    process_videos([video])
  end

  def process_videos(videos) do
    GenStage.call(__MODULE__, {:process_videos, videos})
  end

  ## Server

  def init(:ok) do
    {:producer, nil}
  end

  def handle_call({:process_videos, videos}, _from, state) do
    {:reply, :ok, videos, state}
  end

  def handle_demand(demand, state) do
    {:noreply, [], state}
  end
end
