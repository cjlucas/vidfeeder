defmodule Log do
  defmacro __using__(_opts) do
    quote do
      require Logger
      require Log
    end
  end

  defmacro debug(msg, event_metadata \\ nil) do
    log_event(:debug, msg, event_metadata)
  end

  defmacro error(msg, event_metadata \\ nil) do
    log_event(:error, msg, event_metadata)
  end

  defmacro info(msg, event_metadata \\ nil) do
    log_event(:info, msg, event_metadata)
  end

  defmacro warn(msg, event_metadata \\ nil) do
    log_event(:warn, msg, event_metadata)
  end

  def add_context(context_metadata) do
    context =
      Logger.metadata
      |> Keyword.get(:context, [])
      |> Keyword.merge(context_metadata)

    Logger.metadata(context: context)
  end

  def add_context(context_metadata, fun) do
    prev_context = Logger.metadata |> Keyword.get(:context)
    add_context(context_metadata)

    try do
      fun.()
    rescue
      e ->
        reraise e, __STACKTRACE__
    after
      Logger.metadata(context: prev_context)
    end
  end

  defp log_event(level, msg, event_metadata) do
    quote bind_quoted: [level: level, msg: msg, event_metadata: event_metadata] do
      Logger.metadata(event: event_metadata)

      case level do
        :debug ->
          Logger.debug(msg)

        :error ->
          Logger.error(msg)

        :info ->
          Logger.info(msg)

        :warn ->
          Logger.warn(msg)
        end

      Logger.metadata(event: nil)
    end
  end
end
