defmodule VidFeeder.YouTubeVideo do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "youtube_videos" do
    field :video_id, :string
    field :title, :string
    field :description, :string
    field :duration, :integer
    field :mime_type, :string
    field :size, :integer
    field :published_at, :utc_datetime

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
      published_at: video.published_at
    })
  end

  def changeset(youtube_video, params \\ %{}) do
    youtube_video
    |> cast(params, [:title, :description, :duration, :mime_type, :size, :published_at])
  end
end
