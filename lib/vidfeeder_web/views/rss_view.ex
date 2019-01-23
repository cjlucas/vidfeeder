defmodule VidFeederWeb.RssView do
  use VidFeederWeb, :view

  def rss_duration(seconds) do
    minutes = Integer.floor_div(seconds, 60)
    seconds = Integer.mod(seconds, 60)

    [minutes, seconds]
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join(":")
  end

  def rss_pubdate(dt) do
    Timex.format!(dt, "{WDshort}, {D} {Mshort} {YYYY} {h24}:{m}:{s} {Zabbr}")
  end

  def rss_enclosure_url(item) do
    video_url = "https://www.youtube.com/watch?v=#{item.source_id}"
    "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"
  end
end
