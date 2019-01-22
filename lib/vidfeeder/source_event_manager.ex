defmodule VidFeeder.SourceEventManager do
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(_opts) do
    Registry.start_link(keys: :duplicate, name: __MODULE__)
  end

  def register(event_name, source_id) do
    Registry.register(__MODULE__, {event_name, source_id}, nil)
  end

  def notify(event_name, source) do
    __MODULE__
    |> Registry.dispatch({event_name, source.id}, fn subscribers ->
      Enum.each(subscribers, fn {pid, _} ->
        send(pid, {event_name, source.id})
      end)
    end)
  end
end
