defmodule VidFeeder.SourceImporter.YoutubeDlSourceImporter do
  alias VidFeeder.{
    Repo,
    YoutubeDlSource,
    YoutubeDlItem,
    YoutubeDlUpdater
  }

  import Ecto.Query

  def run(youtube_dl_source) do
    youtube_dl_source = Repo.preload(youtube_dl_source, :items)

    items_by_youtube_dl_id =
      Enum.map(youtube_dl_source.items, fn item ->
        {item.youtube_dl_id, item}
      end)
      |> Enum.into(%{})

    {json, _exit_code} = System.cmd(YoutubeDlUpdater.path(), ["-j", youtube_dl_source.url])

    Stream.each(string_io_line_stream(json), fn line ->
      attrs = %{
        youtube_dl_source_id: youtube_dl_source.id,
        youtube_dl_id: line["id"],
        title: line["title"],
        description: line["description"],
        published_at: Timex.parse!(line["upload_date"], "{YYYY}{0M}{D}"),
        duration: line["duration"]
      }

      case Map.get(items_by_youtube_dl_id, attrs[:youtube_dl_id]) do
        nil ->
          attrs
          |> YoutubeDlItem.create_changeset()
          |> Repo.insert!()

        item ->
          item
          |> YoutubeDlItem.changeset(attrs)
          |> Repo.update!()
      end
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
