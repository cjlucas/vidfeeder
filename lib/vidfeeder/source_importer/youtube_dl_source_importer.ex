defmodule VidFeeder.SourceImporter.YoutubeDlSourceImporter do
  alias VidFeeder.{
    Repo,
    YoutubeDlSource,
    YoutubeDlItem
  }

  import Ecto.Query

  def run(youtube_dl_source) do
    {json, _exit_code} = System.cmd("youtube-dl", ["-j", youtube_dl_source.url])

    Stream.each(string_io_line_stream(json), fn line ->
      YoutubeDlItem.create_changeset(%{
        youtube_dl_source_id: youtube_dl_source.id,
        youtube_dl_id: line["id"],
        title: line["title"],
        description: line["description"],
        duration: line["duration"]
      })
      |> IO.inspect()
      |> Repo.insert!()
    end)
    |> Enum.to_list()
  end

  defp string_io_line_stream(output) do
    Stream.resource(
      # start_fn
      fn ->
        {:ok, pid} = StringIO.open(output)

        IO.inspect(pid)
        pid
      end,

      # next_fn
      fn pid ->
        case IO.read(pid, :line) do
          :eof -> {:halt, pid}
          line -> {[Jason.decode!(line)], pid}
        end
      end,

      # after_fun
      fn pid -> StringIO.close(pid) end
    )
  end
end
