defmodule VidFeeder.YouTubePlaylistItem do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "youtube_playlist_items" do
    field(:playlist_item_id, :string)
    field(:position, :integer)
    field(:published_at, :utc_datetime)

    belongs_to(:video, VidFeeder.YouTubeVideo, on_replace: :update)

    belongs_to(:playlist, VidFeeder.YouTubePlaylist)

    timestamps()
  end

  def build(playlist, playlist_item_id) do
    Ecto.build_assoc(playlist, :items, playlist_item_id: playlist_item_id)
  end

  def api_changeset(youtube_playlist_item, %YouTube.PlaylistItem{} = playlist_item) do
    changeset(youtube_playlist_item, %{
      position: playlist_item.position,
      video_id: playlist_item.video_id
    })
  end

  def changeset(youtube_playlist_item, params \\ %{}) do
    youtube_playlist_item
    |> cast(params, [:position])
    |> put_assoc(:video, Map.take(params, [:video_id]))
  end
end
