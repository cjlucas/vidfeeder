defmodule VidFeeder.Feed do
  use VidFeeder.Schema

  alias VidFeeder.Repo

  import Ecto.Changeset

  @required_fields [:source, :source_type, :source_id]

  @permitted_params @required_fields ++ [:title, :description, :image_url]

  schema "feeds" do
    field :source, :string
    field :source_type, :string
    field :source_id, :string
    field :title, :string
    field :description, :string
    field :image_url, :string
    field :state, :string
    field :last_refreshed_at, :utc_datetime

    has_many :subscriptions, VidFeeder.Subscription
    many_to_many :items, VidFeeder.Item,
      join_through: "feeds_items",
      on_replace: :delete

    timestamps()
  end

  def create_changeset(feed, params \\ %{}) do
    feed
    |> cast(params, @required_fields)
  end

  def changeset(feed, params \\ %{}) do
    feed
    |> cast(params, @permitted_params)
    |> validate_required(@required_fields)
  end

  def insert_or_get_existing!(changeset) do
    params =
      [:source, :source_type, :source_id]
      |> Enum.map(fn field ->
        {field, get_field(changeset, field)}
      end)
      |> Enum.into(%{})

    case Repo.get_by(__MODULE__, params) do
      nil ->
        Repo.insert!(changeset)
      feed ->
        feed
    end
  end
end
