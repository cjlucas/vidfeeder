defmodule VidFeeder.SourceProcessorMonitor do
  use GenServer
  use Log

  alias VidFeeder.{Repo, Source}

  ## Client

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def monitor(source) do
    GenServer.call(__MODULE__, {:monitor, source})
  end

  def demonitor do
    GenServer.call(__MODULE__, :demonitor)
  end

  ## Server

  def init(:ok) do
    Process.flag(:trap_exit, true)

    {:ok, %{}}
  end

  def handle_call({:monitor, source}, {pid, _}, state) do
    Log.info("Monitoring SourceProcessor", source_id: source.id)
    Process.monitor(pid)

    {:reply, :ok, Map.put(state, pid, source.id)}
  end

  def handle_call(:demonitor, {pid, _}, state) do
    {:reply, :ok, Map.delete(state, pid)}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    source_id = Map.get(state, pid)

    unless source_id == nil do
      Log.info("Received down message", source_id: source_id, pid: pid, reason: inspect(reason))
      mark_source_as_failed(source_id)
    end

    {:noreply, Map.delete(state, pid)}
  end

  def terminate(reason, state) do
    Log.info("Received terminate. Marking currently processing sources as failed", reason: inspect(reason))
    Enum.each(state, fn {_pid, source_id} -> mark_source_as_failed(source_id) end)
  end

  defp mark_source_as_failed(source_id) do
    Source
    |> Repo.get(source_id)
    |> Source.changeset(%{state: "failed"})
    |> Repo.update!
  end
end
