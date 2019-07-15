defmodule VidFeeder.SourceProcessor do
  use GenStage
  use Log

  alias VidFeeder.{
    SourceImporter,
    SourceEventManager,
    SourceProcessorMonitor,
  }

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    subscribe_to_opts = [{VidFeeder.SourceScheduler, max_demand: 1}]
    {:consumer, nil, subscribe_to: subscribe_to_opts}
  end

  def handle_events(sources, _from, state) do
    Enum.each(sources, fn source ->
      Log.info("Importing source", source_id: source.id)

      Log.add_context([source_id: source.id], fn ->
        :ok = SourceProcessorMonitor.monitor(source)
        :ok = SourceImporter.run(source)

        SourceEventManager.notify(:source_processed, source)

        :ok = SourceProcessorMonitor.demonitor
      end)
    end)

    {:noreply, [], state}
  end
end
