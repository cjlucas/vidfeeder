defmodule VidFeeder.Source do
  use VidFeeder.Schema

  alias VidFeeder.{
    YouTubePlaylist,
    YouTubeChannel,
    YouTubeUser
  }

  import Ecto.Changeset

  schema "sources" do
    field :state, :string
    field :last_refreshed_at, :string

    belongs_to :youtube_playlist, VidFeeder.YouTubePlaylist
    belongs_to :youtube_channel, VidFeeder.YouTubeChannel
    belongs_to :youtube_user, VidFeeder.YouTubeUser

    timestamps()
  end

  def build(underlying_source) do
    source = %__MODULE__{state: "initial"}

    case underlying_source do
      %YouTubePlaylist{} = playlist ->
        %{source | youtube_playlist: playlist}

      %YouTubeChannel{} = channel ->
        %{source | youtube_channel: channel}

      %YouTubeUser{} = user ->
        %{source | youtube_user: user}
    end
  end

  def changeset(source, params \\ %{}) do
    source
    |> cast(params, [:state, :last_refreshed_at])
  end
end
