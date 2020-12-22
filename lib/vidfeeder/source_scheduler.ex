defmodule VidFeeder.SourceScheduler do
  use GenStage

  defmodule State do
    defstruct pending_demand: 0, timer_ref: nil
  end

  alias VidFeeder.{
    Repo,
    Source
  }

  import Ecto.Query

  ## Client

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def process_source(source) do
    GenStage.call(__MODULE__, {:process_source, source})
  end

  ## Server

  def init(:ok) do
    {:ok, tref} = :timer.send_interval(60 * 1000, :timer_fired)
    {:producer, %State{timer_ref: tref}}
  end

  def handle_call({:process_source, source}, _from, state) do
    {:reply, :ok, [source], state}
  end

  def handle_demand(demand, state) do
    %{pending_demand: pending_demand} = state

    fulfill_demand(demand + pending_demand, state)
  end

  def handle_info(:timer_fired, %{pending_demand: demand} = state) do
    fulfill_demand(demand, state)
  end

  defp fulfill_demand(demand, state) when demand == 0, do: {:noreply, [], state}

  defp fulfill_demand(demand, state) do
    sources =
      Repo.all(
        from(s in Source,
          where:
            (s.last_refreshed_at <= datetime_add(^DateTime.utc_now(), -1, "hour") or
               is_nil(s.last_refreshed_at)) and s.state != "processing" and s.state != "failed",
          limit: ^demand
        )
      )

    {:ok, sources} =
      Repo.transaction(fn ->
        Enum.map(sources, fn source ->
          source |> Source.changeset(%{state: "processing"}) |> Repo.update!()
        end)
      end)

    state = Map.put(state, :pending_demand, demand - Enum.count(sources))
    {:noreply, sources, state}
  end
end
