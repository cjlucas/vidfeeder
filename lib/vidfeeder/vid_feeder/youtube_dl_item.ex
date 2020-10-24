defmodule VidFeeder.VidFeeder.YoutubeDlItem do
  use VidFeeder.Schema
  import Ecto.Changeset

  schema "vidfeeder_youtube_dl_items" do
    field(:youtube_dl_id, :string)
    field(:description, :string)
    field(:duration, :integer)
    field(:image_url, :string)
    field(:published_at, :naive_datetime)
    field(:title, :string)

    belongs_to(:youtube_dl_source, VidFeeder.YoutubeDlSource)

    timestamps()
  end

  @doc false
  def create_changeset(attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  @doc false
  def changeset(youtube_dl_item, attrs) do
    youtube_dl_item
    |> cast(attrs, [
      :youtube_dl_id,
      :title,
      :description,
      :duration,
      :image_url,
      :published_at,
      :youtube_dl_source_id
    ])
    |> validate_required([
      :youtube_dl_id,
      :title,
      :youtube_dl_source_id
    ])
  end
end
