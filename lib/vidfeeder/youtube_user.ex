defmodule VidFeeder.YouTubeUser do
  use VidFeeder.Schema

  import Ecto.Changeset

  schema "youtube_users" do
    field :username, :string

    belongs_to :channel, VidFeeder.YouTubeChannel

    timestamps()
  end

  def create_changeset(username) do
    %__MODULE__{}
    |> change
    |> put_change(:username, username)
    |> unique_constraint(:username)
  end

  def user_channel_changeset(youtube_user, youtube_channel) do
    youtube_user
    |> change
    |> put_assoc(:channel, youtube_channel)
  end
end
