defmodule VidFeeder.YouTubeVideo do
  use VidFeeder.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false, read_after_writes: true}

  schema "youtube_videos" do
    field(:video_id, :string)
    field(:title, :string)
    field(:description, :string)
    field(:duration, :integer)
    field(:mime_type, :string)
    field(:size, :integer)
    field(:published_at, :utc_datetime)
    field(:region_restricted, :boolean)
    field(:allowed_countries, {:array, :string})
    field(:blocked_countries, {:array, :string})

    timestamps()
  end

  def build(video_id) do
    %__MODULE__{video_id: video_id}
  end

  def api_changeset(youtube_video, %YouTube.Video{} = video) do
    changeset(youtube_video, %{
      title: video.title,
      description: video.description,
      duration: video.duration,
      published_at: video.published_at,
      region_restricted: video.region_restricted,
      allowed_countries: video.allowed_countries,
      blocked_countries: video.blocked_countries
    })
  end

  def changeset(youtube_video, params \\ %{}) do
    youtube_video
    |> cast(
      params,
      [
        :title,
        :description,
        :duration,
        :mime_type,
        :size,
        :published_at,
        :region_restricted,
        :allowed_countries,
        :blocked_countries
      ]
    )
  end

  def available_in_united_states?(%{region_restricted: restricted}) when not restricted, do: true

  def available_in_united_states?(video) do
    "US" in video.allowed_countries || !("US" in video.blocked_countries)
  end
end
