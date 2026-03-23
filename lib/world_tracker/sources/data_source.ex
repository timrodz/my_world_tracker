defmodule WorldTracker.Sources.DataSource do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Markets.Ticker

  schema "data_sources" do
    field :name, :string
    field :slug, :string
    field :base_url, :string

    has_many :tickers, Ticker

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(data_source, attrs) do
    data_source
    |> cast(attrs, [:name, :slug, :base_url])
    |> validate_required([:name, :slug, :base_url])
    |> unique_constraint(:slug)
  end
end
