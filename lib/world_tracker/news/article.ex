defmodule WorldTracker.News.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Sources.DataSource

  schema "news_articles" do
    belongs_to :data_source, DataSource

    field :guid, :string
    field :title, :string
    field :description, :string
    field :url, :string
    field :image_url, :string
    field :author, :string
    field :categories, {:array, :string}, default: []
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [
      :data_source_id,
      :guid,
      :title,
      :description,
      :url,
      :image_url,
      :author,
      :categories,
      :published_at
    ])
    |> validate_required([:data_source_id, :guid, :title, :url])
    |> unique_constraint([:data_source_id, :guid])
  end
end
