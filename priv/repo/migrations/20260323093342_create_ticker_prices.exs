defmodule WorldTracker.Repo.Migrations.CreateTickerPrices do
  use Ecto.Migration

  def change do
    create table(:ticker_prices) do
      add :price, :decimal, null: false
      add :fetched_at, :utc_datetime, null: false
      add :ticker_id, references(:tickers, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:ticker_prices, [:ticker_id])
    create index(:ticker_prices, [:ticker_id, :fetched_at])
  end
end
