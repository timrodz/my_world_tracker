defmodule WorldTracker.Markets.TickerPrice do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Markets.Ticker

  schema "ticker_prices" do
    field :price, :decimal
    field :fetched_at, :utc_datetime

    belongs_to :ticker, Ticker

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticker_price, attrs) do
    ticker_price
    |> cast(attrs, [:price, :fetched_at, :ticker_id])
    |> validate_required([:price, :fetched_at, :ticker_id])
    |> assoc_constraint(:ticker)
  end
end
