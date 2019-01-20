defmodule VidFeeder.YouTubeChannel do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "youtube_channels" do
    field :channel_id, :string
    field :title, :string
    field :description, :string
    field :image_url, :string

    belongs_to :uploads_playlist, VidFeeder.YouTubePlaylist
    has_one :user, VidFeeder.YouTubeUser, foreign_key: :channel_id

    timestamps()
  end

  def build(channel_id) do
    %__MODULE__{channel_id: channel_id}
  end

  def api_changeset(youtube_channel, %YouTube.Channel{} = channel) do
    changeset(youtube_channel, %{
      title: channel.title,
      description: channel.description,
      image_url: channel.image_url
    })
  end

  def changeset(youtube_channel, params \\ %{}) do
    youtube_channel
    |> cast(params, [:title, :description, :image_url])
    |> cast_assoc(:user)
  end
end
