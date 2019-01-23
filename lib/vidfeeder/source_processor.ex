defmodule VidFeeder.SourceProcessor do
  use GenStage

  alias VidFeeder.{
    SourceImporter,
    SourceEventManager
  }

  require Logger

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    subscribe_to_opts = [{VidFeeder.SourceScheduler, max_demand: 1}]
    {:consumer, nil, subscribe_to: subscribe_to_opts}
  end

  def handle_events(sources, _from, state) do
    Enum.each(sources, fn source ->
      Logger.info("Importing source: #{source.id}")
      SourceImporter.run(source)
      SourceEventManager.notify(:source_processed, source)
    end)

    {:noreply, [], state}
  end
end
