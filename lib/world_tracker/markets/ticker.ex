defmodule WorldTracker.Markets.Ticker do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Markets.TickerPrice
  alias WorldTracker.Sources.DataSource

  schema "tickers" do
    field :symbol, :string
    field :name, :string

    belongs_to :data_source, DataSource
    has_many :ticker_prices, TickerPrice

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticker, attrs) do
    ticker
    |> cast(attrs, [:symbol, :name, :data_source_id])
    |> validate_required([:symbol, :name, :data_source_id])
    |> assoc_constraint(:data_source)
    |> unique_constraint([:data_source_id, :symbol])
  end
end
