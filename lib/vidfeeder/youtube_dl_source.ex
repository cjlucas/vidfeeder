defmodule VidFeeder.YoutubeDlSource do
  use VidFeeder.Schema
  import Ecto.Changeset

  schema "youtube_dl_sources" do
    field(:url, :string)

    has_many(:items, VidFeeder.YoutubeDlItem)

    timestamps()
  end

  @doc false
  def create_changeset(url) do
    %__MODULE__{}
    |> change
    |> put_change(:url, url)
  end

  @doc false
  def changeset(youtube_dl_source, attrs) do
    youtube_dl_source
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
