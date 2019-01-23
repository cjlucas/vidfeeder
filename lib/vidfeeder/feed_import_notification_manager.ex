defmodule VidFeeder.FeedImportNotificationManager do
  use GenServer

  alias VidFeeder.{
    Repo,
    Source,
    FeedGenerator,
    SourceEventManager
  }

  ## Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def notify_user(email, source) do
    GenServer.call(__MODULE__, {:notify_user, email, source})
  end

  def import_complete(source) do
    GenServer.call(__MODULE__, {:import_complete, source})
  end

  ## Server

  def init(:ok) do
    {:ok, table} = :dets.open_file(:"feed_notification_manager.dets", type: :bag)

    {:ok, table}
  end

  def handle_call({:notify_user, email, source}, _from, table) do
    ret =
      case source.state do
        "imported" ->
          notify(email, source)

        _ ->
          {:ok, _} = SourceEventManager.register(:source_processed, source.id)
          :dets.insert(table, {source.id, email})
      end

    {:reply, ret, table}
  end

  def handle_info({:source_processed, source_id}, table) do
    emails = table |> :dets.lookup(source_id) |> Enum.map(&elem(&1, 1))

    unless Enum.empty?(emails) do
      source = Repo.get(Source, source_id)
      notify(emails, source)

      :ok = :dets.delete(table, source_id)
    end

    {:noreply, table}
  end

  defp notify(emails, source) do
    feed = FeedGenerator.generate(source)
    :ok = VidFeeder.FeedProcessedMailer.send(emails, feed)
  end
end
