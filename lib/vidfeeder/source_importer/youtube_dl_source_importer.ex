defmodule VidFeeder.SourceImporter.YoutubeDlSourceImporter do
  alias VidFeeder.{
    Repo,
    YoutubeDlSource,
    YoutubeDlItem,
    YoutubeDlUpdater
  }

  import Ecto.Query

  use Log

  @proxies [
    "nve.socks.ipvanish.com",
    "tll.socks.ipvanish.com",
    "sjo.socks.ipvanish.com",
    "gig.socks.ipvanish.com",
    "gru.socks.ipvanish.com",
    "lis.socks.ipvanish.com",
    "osl.socks.ipvanish.com",
    "akl.socks.ipvanish.com",
    "rix.socks.ipvanish.com",
    "cph.socks.ipvanish.com",
    "rkv.socks.ipvanish.com",
    "sel.socks.ipvanish.com"
  ]

  def run(youtube_dl_source) do
    youtube_dl_source = Repo.preload(youtube_dl_source, :items)

    items_by_youtube_dl_id =
      Enum.map(youtube_dl_source.items, fn item ->
        {item.youtube_dl_id, item}
      end)
      |> Enum.into(%{})

    Temp.track!()
    {:ok, temp_fd, temp_file_path} = Temp.open("youtube-dl-archive-file")

    archive_file_contents = items_by_youtube_dl_id |> Map.keys() |> Enum.join("\n")

    :ok = IO.puts(temp_fd, archive_file_contents)
    File.close(temp_fd)

    proxy_url =
      "socks5://#{System.get_env("PROXY_USER")}:#{System.get_env("PROXY_PASS")}@#{Enum.random(@proxies)}"

    youtube_dl_cmd = YoutubeDlUpdater.path()

    youtube_dl_args = [
      "-j",
      "--proxy",
      proxy_url,
      "--download-archive",
      temp_file_path,
      youtube_dl_source.url
    ]

    Log.info("Executing youtube-dl", cmd: youtube_dl_cmd, args: youtube_dl_args)

    {json, _exit_code} = System.cmd(youtube_dl_cmd, youtube_dl_args)

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

    Temp.cleanup()
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
