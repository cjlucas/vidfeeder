defmodule RequestLogger do
  use Log

  alias Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    request_id = generate_request_id()

    Log.info("Request received",
      method: conn.method,
      path: conn.request_path,
      # remote_ip: format_ip(conn.remote_ip),
      query: conn.query_string,
      host: conn.host,
      headers: format_headers(conn.req_headers),
      request_id: request_id
    )

    Log.add_context(request_id: request_id)

    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      stop = System.monotonic_time()
      diff = System.convert_time_unit(stop - start, :native, :microsecond)

      status = Integer.to_string(conn.status)

      Log.clear_context()
      Log.info("Sent response",
        status: status,
        duration_us: diff,
        headers: format_headers(conn.resp_headers),
        request_id: request_id
      )

      conn
    end)
  end

  defp format_ip({o1, o2, o3, o4}), do: "#{o1}.#{o2}.#{o3}.#{o4}"

  defp format_headers(headers) do
    Enum.into(headers, %{})
  end

  defp generate_request_id do
    :crypto.strong_rand_bytes(16) |> Base.encode32(padding: false, case: :lower)
  end
end
