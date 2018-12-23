defmodule VidFeeder.FeedImportNotificationManager do
  use GenServer

  ## Client
  
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def notify_user(email, feed) do
    GenServer.call(__MODULE__, {:notify_user, email, feed})
  end

  def import_complete(feed) do
    GenServer.call(__MODULE__, {:import_complete, feed})
  end

  ## Server

  def init(:ok) do
    {:ok, table} = :dets.open_file(:"feed_notification_manager.dets", type: :bag)

    {:ok, table}
  end

  def handle_call({:notify_user, email, feed}, _from, table) do
    ret = 
      case feed.state do
        "imported" ->
          notify(email, feed)
          :ok
        _ ->
          :dets.insert(table, {feed.id, email})
      end

    {:reply, ret, table}
  end

  def handle_call({:import_complete, feed}, _from, table) do
    emails = table |> :dets.lookup(feed.id) |> Enum.map(&elem(&1, 1))

    feed = VidFeeder.Repo.get(VidFeeder.Feed, feed.id)

    Enum.each(emails, fn email ->
      notify(email, feed)
    end)

    :ok = :dets.delete(table, feed.id)

    {:reply, :ok, table}
  end

  defp notify(email, feed) do
    :ok = VidFeeder.FeedProcessedMailer.send(email, feed)
  end
end
