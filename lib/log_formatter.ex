defmodule VidFeeder.LogFormatter do
  defmodule LogPayload do
    defstruct message: nil,
              timestamp: nil,
              metadata: [],
              context: [],
              event: []

    @log_metadata_keys [
      :application,
      :module,
      :function,
      :file,
      :line,
      :pid,
      :level
    ]

    @metadata_keys [
      :context,
      :event,
      :metadata
    ]

    def new(level, message, timestamp, metadata) do
      %__MODULE__{
        message: message,
        timestamp: timestamp,
        metadata: Keyword.put(metadata, :level, level)
      }
      |> convert_message_to_binary
      |> stringify_unserializable_values
      |> convert_timestamp
      |> extract_context_metadata
      |> extract_event_metadata
      |> filter_log_metadata
    end

    def encode!(payload) do
      raw_payload = %{
        msg: payload.message,
        timestamp: DateTime.to_iso8601(payload.timestamp),
        metadata: Enum.into(payload.metadata, %{}),
        context: Enum.into(payload.context, %{}),
        event: Enum.into(payload.event, %{})
      }

      json = try do
        Enum.reduce(@metadata_keys, raw_payload, fn key, acc ->
          if Enum.empty?(acc[key]) do
            Map.drop(acc, [key])
          else
            acc
          end
        end)
        |> Poison.encode!()
      rescue
        Poison.EncodeError ->
          encode!(%{ payload | msg: inspect(payload.msg) })
      end

      "#{json}\n"
    end

    defp convert_timestamp(payload) do
      {
        {year, month, day},
        {hour, minute, second, millisecond}
      } = payload.timestamp

      dt = %DateTime{
        year: year,
        month: month,
        day: day,
        zone_abbr: "UTC",
        hour: hour,
        minute: minute,
        second: second,
        microsecond: {millisecond * 1000, 3},
        utc_offset: 0,
        std_offset: 0,
        time_zone: "Etc/UTC"
      }

      %{payload | timestamp: dt}
    end

    defp convert_message_to_binary(%{message: message} = payload)
         when is_binary(message),
         do: payload

    defp convert_message_to_binary(payload) do
      %{payload | message: :erlang.list_to_binary(payload.message)}
    end

    defp extract_context_metadata(payload) do
      {context, metadata} = Keyword.pop(payload.metadata, :context, [])
      %{payload | context: context, metadata: metadata}
    end

    defp extract_event_metadata(payload) do
      {event, metadata} = Keyword.pop(payload.metadata, :event, [])
      %{payload | event: event, metadata: metadata}
    end

    defp filter_log_metadata(payload) do
      {log_metadata, event_metadata} =
        Enum.reduce(payload.metadata, {[], []}, fn {k, v}, {log_metadata, event_metadata} ->
          if k in @log_metadata_keys do
            log_metadata = Keyword.put(log_metadata, k, v)
            {log_metadata, event_metadata}
          else
            event_metadata = Keyword.put(event_metadata, k, v)
            {log_metadata, event_metadata}
          end
        end)

      event_metadata = Keyword.merge(payload.event, event_metadata)

      %{payload | metadata: log_metadata, event: event_metadata}
    end

    defp stringify_unserializable_values(%{metadata: metadata} = payload) do
      metadata =
        if Keyword.has_key?(metadata, :pid) do
          Keyword.update!(metadata, :pid, &inspect/1)
        else
          metadata
        end

      %{payload | metadata: metadata}
    end
  end

  def format(level, message, timestamp, metadata) do
    LogPayload.new(level, message, timestamp, metadata) |> LogPayload.encode!()
  end
end
