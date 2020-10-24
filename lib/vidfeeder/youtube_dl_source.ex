defmodule VidFeeder.YoutubeDlSource do
  use VidFeeder.Schema
  import Ecto.Changeset

  schema "youtube_dl_sources" do
    field(:url, :string)

    has_one(:source, VidFeeder.Source, foreign_key: :youtube_dl_source_id)
    has_many(:items, VidFeeder.YoutubeDlItem)

    timestamps()
  end

  ## Helpers

  def to_feed(youtube_dl_source) do
    items =
      youtube_dl_source
      |> VidFeeder.Repo.preload(:items)
      |> Map.get(:items)
      |> Enum.map(&VidFeeder.YoutubeDlItem.to_feed_item/1)

    %VidFeeder.Feed{
      title: youtube_dl_source.url,
      items: items
    }
  end

  ## Changesets

  @doc false
  def create_changeset(url) do
    %__MODULE__{}
    |> change
    |> put_change(:url, url)
    |> unique_constraint(:url)
  end

  @doc false
  def changeset(youtube_dl_source, attrs) do
    youtube_dl_source
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
