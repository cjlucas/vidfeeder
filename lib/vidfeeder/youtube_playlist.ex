defmodule VidFeeder.YouTubePlaylist do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "youtube_playlists" do
    field(:playlist_id, :string)
    field(:etag, :string)
    field(:title, :string)
    field(:description, :string)
    field(:image_url, :string)

    has_one(:source, VidFeeder.Source, foreign_key: :youtube_playlist_id)

    has_many(:items, VidFeeder.YouTubePlaylistItem, foreign_key: :playlist_id, on_replace: :delete)

    timestamps()
  end

  def create_changeset(playlist_id) do
    %__MODULE__{}
    |> change
    |> put_change(:playlist_id, playlist_id)
    |> unique_constraint(:playlist_id)
  end

  def api_changeset(youtube_playlist, %YouTube.Playlist{} = playlist) do
    changeset(youtube_playlist, %{
      title: playlist.title,
      description: playlist.description,
      image_url: playlist.image_url,
      etag: playlist.etag
    })
  end

  def changeset(playlist, params \\ %{}) do
    playlist
    |> cast(params, [:title, :description, :etag, :image_url])
  end
end
