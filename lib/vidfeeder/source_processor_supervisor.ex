defmodule VidFeeder.SourceProcessorSupervisor do
  use Supervisor

  def start_link(_opts) do
    children = [
      VidFeeder.SourceProcessor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
