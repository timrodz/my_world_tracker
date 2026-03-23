alias WorldTracker.Markets
alias WorldTracker.Repo
alias WorldTracker.Sources

yahoo_finance =
  Repo.get_by(Sources.DataSource, slug: "yahoo_finance") ||
    Repo.insert!(%Sources.DataSource{
      name: "Yahoo Finance",
      slug: "yahoo_finance",
      base_url: "https://finance.yahoo.com"
    })

for ticker <- [
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
    ] do
  Repo.get_by(Markets.Ticker, data_source_id: yahoo_finance.id, symbol: ticker.symbol) ||
    Repo.insert!(%Markets.Ticker{
      data_source_id: yahoo_finance.id,
      symbol: ticker.symbol,
      name: ticker.name
    })
end
