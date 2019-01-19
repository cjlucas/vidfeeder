defmodule YouTube.User do
  defstruct [:channel, :username, :description, :image_url]

  alias GoogleApi.YouTube.V3.Api
  alias YouTube.Channel

  def info(conn, user_name) do
    {:ok, resp} = Api.Channels.youtube_channels_list(conn, "id", forUsername: user_name)
    
    channel_id =
      resp.items
      |> Enum.map(fn channel -> channel.id end)
      |> List.first

    channel = Channel.info(conn, channel_id)

    %__MODULE__{
      channel: channel,
      username: user_name,
      description: channel.description,
      image_url: channel.image_url
    }
  end

  def uploads(conn, user_name) do
    {:ok, resp} = Api.Channels.youtube_channels_list(conn, "id", forUsername: user_name)

    channel_id =
      resp.items
      |> Enum.map(fn channel -> channel.id end)
      |> List.first

    Channel.uploads(conn, channel_id)
  end
  
  defp image_url(user) do
    sizes = [:maxres, :high, :medium, :standard, :default]

    Enum.find_value(sizes, fn size ->
      case Map.get(user.snippet.thumbnails, size) do
        nil -> false
        image -> image.url
      end
    end)
  end
end
