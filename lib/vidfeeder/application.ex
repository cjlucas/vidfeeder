defmodule VidFeeder.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(VidFeeder.Repo, []),
      {VidFeeder.FeedImportNotificationManager, []},
      supervisor(VidFeederWeb.Endpoint, []),
      {Task.Supervisor, name: VidFeeder.ImportFeedWorker.TaskSupervisor},
      worker(VidFeeder.ImportFeedStore, []),
      worker(VidFeeder.ImportFeedWorker, []),
      worker(VidFeeder.ImportFeedEnqueuer, []),
      {VidFeeder.SourceScheduler, []},
      {VidFeeder.SourceProcessor, []},
      {VidFeeder.SourceEventManager, []}
    ]

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
end
