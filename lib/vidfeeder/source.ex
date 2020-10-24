defmodule VidFeeder.Source do
  use VidFeeder.Schema

  alias VidFeeder.{
    YouTubePlaylist,
    YouTubeChannel,
    YouTubeUser
  }

  import Ecto.Changeset

  @underlying_sources [
    :youtube_user,
    :youtube_channel,
    :youtube_playlist,
    :youtube_dl_source
  ]

  schema "sources" do
    field(:state, :string)
    field(:last_refreshed_at, :utc_datetime)

    belongs_to(:youtube_playlist, VidFeeder.YouTubePlaylist)
    belongs_to(:youtube_channel, VidFeeder.YouTubeChannel)
    belongs_to(:youtube_user, VidFeeder.YouTubeUser)
    belongs_to(:youtube_dl_source, VidFeeder.VidFeeder.YoutubeDlSource)

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

      %VidFeeder.VidFeeder.YoutubeDlSource{} = youtube_dl_source ->
        %{source | youtube_dl_source: youtube_dl_source}
    end
  end

  def changeset(source, params \\ %{}) do
    source
    |> cast(params, [:state, :last_refreshed_at])
  end

  def underlying_source(source, repo) do
    source = repo.preload(source, @underlying_sources)

    @underlying_sources
    |> Enum.map(&Map.get(source, &1))
    |> Enum.reject(&is_nil/1)
    |> List.first()
  end
end
