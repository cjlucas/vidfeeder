:observer.start

defmodule Foo do
  def run do
    items =
      VidFeeder.Repo.all(VidFeeder.Item)
      |> Enum.filter(fn item -> item.size == nil end)

    items
    |> Enum.chunk_every(div(Enum.count(items), 100))
    |> Enum.map(fn chunk ->
      Task.async(fn ->
        Enum.each(chunk, fn item -> fetch_item_metadata(item) end)
      end)
    end)
    |> Enum.each(&Task.await(&1, :infinity))
  end

  def fetch_item_metadata(item) do
    video_url = "https://www.youtube.com/watch?v=#{item.source_id}"
    url = "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"

    IO.puts "REQUEST"

    case HTTPoison.head(url, [], follow_redirect: true, timeout: 20_000, recv_timeout: 20_000) do
      {:ok, %{status_code: 200} = resp} ->
        %{"Content-Type" => mime_type, "Content-Length" => size} = Enum.into(resp.headers, %{})

        IO.puts "SUCCESS"

        item
        |> Ecto.Changeset.change(%{
          mime_type: mime_type,
          size: size
        })
        |> VidFeeder.Repo.update!
      {:ok, resp} ->
        IO.puts "UNKNOWN RESPONSE"
        IO.inspect resp
      {:error, err} ->
        IO.puts "ERROR #{inspect err}"
        nil
    end
  end
end


Foo.run
