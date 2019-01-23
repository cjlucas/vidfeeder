defmodule VidFeeder.ImportFeedWorker do
  use GenServer

  require Logger

  defmodule State do
    defstruct [:current_feed]
  end

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def import_feed(feed) do
    GenServer.call(__MODULE__, {:import_feed, feed})
  end

  ## Server

  def init(:ok) do
    {:ok, pop_and_import_next_feed(%State{})}
  end

  def handle_call({:import_feed, feed}, _from, state) do
    feed =
      feed
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_change(:state, "importing")
      |> VidFeeder.Repo.update!

    state =
      if is_nil(state.current_feed) do
        start_import_feed_task(state, feed)
      else
        VidFeeder.ImportFeedStore.push(feed)
        state
      end

    {:reply, :ok, state}
  end

  def handle_info({_ref, _}, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _object, reason}, state) do
    Logger.debug("Received DOWN message. Current feed: #{state.current_feed}, reason: #{inspect reason}")

    if reason != :normal do
      feed = VidFeeder.Repo.get(VidFeeder.Feed, state.current_feed)
      unless is_nil(feed) do
        VidFeeder.ImportFeedStore.push(feed)
      end
    end

    {:noreply, pop_and_import_next_feed(state)}
  end

  defp pop_and_import_next_feed(state) do
    case VidFeeder.ImportFeedStore.pop do
      nil ->
        %{state | current_feed: nil}
      feed ->
        start_import_feed_task(state, feed)
    end
  end

  defp start_import_feed_task(state, feed) do
    Task.Supervisor.async_nolink(VidFeeder.ImportFeedWorker.TaskSupervisor, fn ->
      VidFeeder.FeedProcessor.run(feed)
    end)

    %{state | current_feed: feed.id}
  end
end
