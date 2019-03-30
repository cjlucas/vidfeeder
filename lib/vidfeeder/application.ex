defmodule VidFeeder.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      VidFeeder.Repo,
      VidFeeder.FeedImportNotificationManager,
      VidFeederWeb.Endpoint,
      VidFeeder.SourceProcessorMonitor,
      VidFeeder.SourceScheduler,
      VidFeeder.SourceProcessorSupervisor,
      VidFeeder.SourceEventManager,
      VidFeeder.YouTubeVideoMetadataManager,
    ] ++ workers(50, VidFeeder.YouTubeVideoMetadataWorker, [])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VidFeeder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VidFeederWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp workers(times, module, opts) do
    Enum.map(1..times, fn i ->
      Supervisor.child_spec({module, opts}, id: "#{module}_#{i}")
    end)
  end
end
