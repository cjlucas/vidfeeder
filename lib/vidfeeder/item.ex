defmodule VidFeeder.Item do
  use VidFeeder.Schema

  schema "items" do
    field :title, :string
    field :description, :string
    field :source_id, :string
    field :duration, :integer
    field :image_url, :string
    field :size, :string
    field :mime_type, :string
    field :published_at, :utc_datetime

    many_to_many :feeds, VidFeeder.Feed,
      join_through: "feeds_items",
      on_replace: :delete

    timestamps()
  end
end
