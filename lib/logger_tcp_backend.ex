defmodule LoggerTcpBackend do
  def init({__MODULE__, name}) do
    opts = configure(name)

    case connect(opts) do
      {:ok, fd} -> {:ok, {fd, opts}}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_call({:configure, opts}, {fd, _opts}) do
    {:ok, :ok, {fd, opts}}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({level, _group_leader, {Logger, msg, ts, metadata}}, {fd, opts} = state) do
    msg =
      case Keyword.get(opts, :format) do
        {mod, fun} ->
          apply(mod, fun, [level, msg, ts, metadata])

        nil ->
          msg
      end

    :gen_tcp.send(fd, msg)

    {:ok, state}
  end

  defp configure(name) do
    config = Application.get_env(:logger, name)

    config
    |> Keyword.put_new(:host, "localhost")
  end

  defp connect(opts) do
    host = Keyword.fetch!(opts, :host) |> :erlang.binary_to_list()
    port = Keyword.fetch!(opts, :port)

    :gen_tcp.connect(host, port, [:binary, active: false])
  end
end
