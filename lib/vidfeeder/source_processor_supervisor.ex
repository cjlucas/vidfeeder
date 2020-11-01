defmodule VidFeeder.SourceProcessorSupervisor do
  use Supervisor

  def start_link(_opts) do
    children = workers(3, VidFeeder.SourceProcessor, [])

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  defp workers(times, module, opts) do
    Enum.map(1..times, fn i ->
      Supervisor.child_spec({module, opts}, id: "#{module}_#{i}")
    end)
  end
end
