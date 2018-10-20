defmodule VidFeeder.ImportFeedEnqueuer do
  use GenServer

  alias VidFeeder.{
    Feed,
    Repo
  }

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## Server

  def init(:ok) do
    {:ok, tref} = :timer.send_interval(15 * 60 * 1000, :timer_fired)

    {:ok, %{tref: tref}}
  end

  def handle_info(:timer_fired, state) do
    import Ecto.Query

    query = from f in Feed, where: f.state != "importing"

    Repo.all(query) |> Enum.each(&VidFeeder.ImportFeedWorker.import_feed(&1))

    {:noreply, state}
  end

  def terminate(_reason, state) do
    %{tref: tref} = state

    :timer.cancel(tref)
  end
end
