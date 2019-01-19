defmodule VidFeeder.YouTubePlaylist do
  use VidFeeder.Schema
  
  import Ecto.Changeset

  schema "youtube_playlists" do
    field :playlist_id, :string
    field :etag, :string

    has_many :items, VidFeeder.YouTubePlaylistItem, foreign_key: :playlist_id

    timestamps()
  end

  def build(playlist_id) do
    %__MODULE__{playlist_id: playlist_id}
  end

  def api_changeset(youtube_playlist, %YouTube.Playlist{} = playlist) do
    changeset(youtube_playlist, %{
      etag: playlist.etag
    })
  end

  def changeset(playlist, params \\ %{}) do
    playlist
    |> cast(params, [:etag])
  end
end
