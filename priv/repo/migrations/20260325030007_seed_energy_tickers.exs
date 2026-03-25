defmodule WorldTracker.Repo.Migrations.SeedEnergyTickers do
  use Ecto.Migration

  import Ecto.Query

  @energy_tickers [
    %{symbol: "BZ=F", name: "Brent Crude Oil"},
    %{symbol: "NG=F", name: "Natural Gas"},
    %{symbol: "HO=F", name: "Heating Oil"},
    %{symbol: "RB=F", name: "RBOB Gasoline"}
  ]

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    yahoo_finance_id =
      repo().one(
        from(ds in "data_sources",
          where: ds.slug == "yahoo_finance",
          select: ds.id
        )
      )

    unless is_nil(yahoo_finance_id) do
      rows =
        Enum.map(@energy_tickers, fn ticker ->
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
        rows,
        on_conflict: :nothing,
        conflict_target: [:data_source_id, :symbol]
      )
    end
  end

  def down do
    symbols = Enum.map(@energy_tickers, & &1.symbol)

    yahoo_finance_id =
      repo().one(
        from(ds in "data_sources",
          where: ds.slug == "yahoo_finance",
          select: ds.id
        )
      )

    unless is_nil(yahoo_finance_id) do
      repo().delete_all(
        from(t in "tickers",
          where: t.symbol in ^symbols and t.data_source_id == ^yahoo_finance_id
        )
      )
    end
  end
end
