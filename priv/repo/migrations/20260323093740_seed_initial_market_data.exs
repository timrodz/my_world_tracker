defmodule WorldTracker.Repo.Migrations.SeedInitialMarketData do
  use Ecto.Migration

  import Ecto.Query

  @yahoo_finance %{
    name: "Yahoo Finance",
    slug: "yahoo_finance",
    base_url: "https://finance.yahoo.com"
  }

  @tickers [
    %{symbol: "GC=F", name: "Gold"},
    %{symbol: "SI=F", name: "Silver"},
    %{symbol: "CL=F", name: "Crude Oil"},
    %{symbol: "DX-Y.NYB", name: "US Dollar Index"},
    %{symbol: "EURUSD=X", name: "EUR / USD"},
    %{symbol: "GBPUSD=X", name: "GBP / USD"},
    %{symbol: "^GSPC", name: "S&P 500"},
    %{symbol: "^DJI", name: "Dow Jones"},
    %{symbol: "^RUT", name: "Russell 2000"},
    %{symbol: "^N225", name: "Nikkei 225"}
  ]

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    repo().insert_all(
      "data_sources",
      [Map.merge(@yahoo_finance, %{inserted_at: now, updated_at: now})],
      on_conflict: :nothing,
      conflict_target: [:slug]
    )

    yahoo_finance_id =
      repo().one(
        from(data_source in "data_sources",
          where: data_source.slug == ^@yahoo_finance.slug,
          select: data_source.id
        )
      )

    ticker_rows =
      Enum.map(@tickers, fn ticker ->
        %{
          data_source_id: yahoo_finance_id,
          symbol: ticker.symbol,
          name: ticker.name,
          inserted_at: now,
          updated_at: now
        }
      end)

    repo().insert_all(
      "tickers",
      ticker_rows,
      on_conflict: :nothing,
      conflict_target: [:data_source_id, :symbol]
    )
  end

  def down do
    yahoo_finance_ids =
      repo().all(
        from(data_source in "data_sources",
          where: data_source.slug == ^@yahoo_finance.slug,
          select: data_source.id
        )
      )

    repo().delete_all(
      from(ticker in "tickers",
        where:
          ticker.data_source_id in ^yahoo_finance_ids and
            ticker.symbol in ^Enum.map(@tickers, & &1.symbol)
      )
    )

    repo().delete_all(
      from(data_source in "data_sources",
        where: data_source.slug == ^@yahoo_finance.slug
      )
    )
  end
end
