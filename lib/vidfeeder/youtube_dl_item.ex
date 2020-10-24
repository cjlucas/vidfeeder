defmodule VidFeeder.YoutubeDlItem do
  use VidFeeder.Schema
  import Ecto.Changeset

  schema "youtube_dl_items" do
    field(:youtube_dl_id, :string)
    field(:description, :string)
    field(:duration, :integer)
    field(:image_url, :string)
    field(:published_at, :naive_datetime)
    field(:title, :string)

    belongs_to(:youtube_dl_source, VidFeeder.YoutubeDlSource)

    timestamps()
  end

  ## Helpers

  def to_url(youtube_dl_item) do
    "https://www.youtube.com/watch?v=#{youtube_dl_item.youtube_dl_id}"
  end

  def to_feed_item(item) do
    video_url = to_url(item)
    url = "https://xzsc1ifa0m.execute-api.us-east-1.amazonaws.com/beta?url=#{video_url}"

    %VidFeeder.Item{
      guid: item.youtube_dl_id,
      title: item.title,
      description: item.description,
      duration: item.duration,
      url: url,
      published_at: item.inserted_at
    }
  end

  ## Changesets

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
