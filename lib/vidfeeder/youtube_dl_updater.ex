defmodule VidFeeder.YoutubeDlUpdater do
  use GenServer

  require Logger

  @youtube_dl_latest_url "https://youtube-dl.org/downloads/latest/youtube-dl"

  @refresh_interval 3600 * 1000

  ## Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def path do
    GenServer.call(__MODULE__, :path)
  end

  ## Server

  def init(:ok) do
    {:ok, nil, {:continue, nil}}
  end

  def handle_call(:path, _from, state) do
    {:reply, state, state, @refresh_interval}
  end

  def handle_continue(nil, nil) do
    path = update_youtube_dl_binary
    {:noreply, path, @refresh_interval}
  end

  def handle_info(:timeout, state) do
    path = update_youtube_dl_binary
    {:noreply, path, @refresh_interval}
  end

  defp update_youtube_dl_binary do
    Logger.debug("Fetching latest youtube-dl...")
    {:ok, fd, file_path} = Temp.open("youtube-dl")

    data = HTTPoison.get!(@youtube_dl_latest_url, [], follow_redirect: true).body

    Logger.debug("Got latest youtube-dl, writing to #{file_path}...")

    IO.binwrite(fd, data)
    File.close(fd)

    File.chmod!(file_path, 0o755)

    file_path
  end
end
