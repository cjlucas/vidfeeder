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
end
