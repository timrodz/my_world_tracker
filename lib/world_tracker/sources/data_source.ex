defmodule WorldTracker.Sources.DataSource do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Markets.Ticker
  alias WorldTracker.News.Article
  alias WorldTracker.Shipping.Ship

  @types [:markets, :news, :locations]

  schema "data_sources" do
    field :name, :string
    field :slug, :string
    field :base_url, :string
    field :type, Ecto.Enum, values: @types
    field :endpoint_url, :string

    has_many :tickers, Ticker
    has_many :articles, Article
    has_many :ships, Ship

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(data_source, attrs) do
    data_source
    |> cast(attrs, [:name, :slug, :base_url, :type, :endpoint_url])
    |> validate_required([:name, :slug, :base_url])
    |> validate_inclusion(:type, @types)
    |> unique_constraint(:slug)
  end
end
