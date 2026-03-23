defmodule WorldTracker.MarketsTest do
  use WorldTracker.DataCase

  alias WorldTracker.Markets

  describe "tickers" do
    alias WorldTracker.Markets.Ticker

    import WorldTracker.MarketsFixtures
    import WorldTracker.SourcesFixtures

    @invalid_attrs %{name: nil, symbol: nil, data_source_id: nil}

    test "list_tickers/0 returns all tickers" do
      ticker = ticker_fixture()

      assert Enum.any?(Markets.list_tickers(), fn listed_ticker ->
               listed_ticker.id == ticker.id and
                 listed_ticker.data_source.id == ticker.data_source_id
             end)
    end

    test "get_ticker!/1 returns the ticker with given id" do
      ticker = ticker_fixture()
      fetched_ticker = Markets.get_ticker!(ticker.id)
      assert fetched_ticker.id == ticker.id
      assert fetched_ticker.data_source.id == ticker.data_source_id
    end

    test "create_ticker/1 with valid data creates a ticker" do
      data_source = data_source_fixture()
      valid_attrs = %{name: "some name", symbol: "some symbol", data_source_id: data_source.id}

      assert {:ok, %Ticker{} = ticker} = Markets.create_ticker(valid_attrs)
      assert ticker.name == "some name"
      assert ticker.symbol == "some symbol"
      assert ticker.data_source_id == data_source.id
    end

    test "create_ticker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Markets.create_ticker(@invalid_attrs)
    end

    test "update_ticker/2 with valid data updates the ticker" do
      ticker = ticker_fixture()
      data_source = data_source_fixture()

      update_attrs = %{
        name: "some updated name",
        symbol: "some updated symbol",
        data_source_id: data_source.id
      }

      assert {:ok, %Ticker{} = ticker} = Markets.update_ticker(ticker, update_attrs)
      assert ticker.name == "some updated name"
      assert ticker.symbol == "some updated symbol"
      assert ticker.data_source_id == data_source.id
    end

    test "update_ticker/2 with invalid data returns error changeset" do
      ticker = ticker_fixture()
      assert {:error, %Ecto.Changeset{}} = Markets.update_ticker(ticker, @invalid_attrs)

      fetched_ticker = Markets.get_ticker!(ticker.id)
      assert fetched_ticker.id == ticker.id
      assert fetched_ticker.symbol == ticker.symbol
    end

    test "delete_ticker/1 deletes the ticker" do
      ticker = ticker_fixture()
      assert {:ok, %Ticker{}} = Markets.delete_ticker(ticker)
      assert_raise Ecto.NoResultsError, fn -> Markets.get_ticker!(ticker.id) end
    end

    test "change_ticker/1 returns a ticker changeset" do
      ticker = ticker_fixture()
      assert %Ecto.Changeset{} = Markets.change_ticker(ticker)
    end
  end

  describe "ticker_prices" do
    alias WorldTracker.Markets.TickerPrice

    import WorldTracker.MarketsFixtures

    @invalid_attrs %{price: nil, fetched_at: nil, ticker_id: nil}

    test "list_ticker_prices/0 returns all ticker_prices" do
      ticker_price = ticker_price_fixture()

      assert Enum.any?(Markets.list_ticker_prices(), fn listed_ticker_price ->
               listed_ticker_price.id == ticker_price.id and
                 listed_ticker_price.ticker.id == ticker_price.ticker_id
             end)
    end

    test "get_ticker_price!/1 returns the ticker_price with given id" do
      ticker_price = ticker_price_fixture()
      fetched_ticker_price = Markets.get_ticker_price!(ticker_price.id)
      assert fetched_ticker_price.id == ticker_price.id
      assert fetched_ticker_price.ticker.id == ticker_price.ticker_id
    end

    test "create_ticker_price/1 with valid data creates a ticker_price" do
      ticker = ticker_fixture()
      valid_attrs = %{price: "120.5", fetched_at: ~U[2026-03-22 09:33:00Z], ticker_id: ticker.id}

      assert {:ok, %TickerPrice{} = ticker_price} = Markets.create_ticker_price(valid_attrs)
      assert ticker_price.price == Decimal.new("120.5")
      assert ticker_price.fetched_at == ~U[2026-03-22 09:33:00Z]
      assert ticker_price.ticker_id == ticker.id
    end

    test "create_ticker_price/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Markets.create_ticker_price(@invalid_attrs)
    end

    test "update_ticker_price/2 with valid data updates the ticker_price" do
      ticker_price = ticker_price_fixture()
      update_attrs = %{price: "456.7", fetched_at: ~U[2026-03-23 09:33:00Z]}

      assert {:ok, %TickerPrice{} = ticker_price} =
               Markets.update_ticker_price(ticker_price, update_attrs)

      assert ticker_price.price == Decimal.new("456.7")
      assert ticker_price.fetched_at == ~U[2026-03-23 09:33:00Z]
    end

    test "update_ticker_price/2 with invalid data returns error changeset" do
      ticker_price = ticker_price_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Markets.update_ticker_price(ticker_price, @invalid_attrs)

      fetched_ticker_price = Markets.get_ticker_price!(ticker_price.id)
      assert fetched_ticker_price.id == ticker_price.id
      assert fetched_ticker_price.price == ticker_price.price
    end

    test "delete_ticker_price/1 deletes the ticker_price" do
      ticker_price = ticker_price_fixture()
      assert {:ok, %TickerPrice{}} = Markets.delete_ticker_price(ticker_price)
      assert_raise Ecto.NoResultsError, fn -> Markets.get_ticker_price!(ticker_price.id) end
    end

    test "change_ticker_price/1 returns a ticker_price changeset" do
      ticker_price = ticker_price_fixture()
      assert %Ecto.Changeset{} = Markets.change_ticker_price(ticker_price)
    end
  end

  describe "latest_prices/0" do
    import WorldTracker.MarketsFixtures

    test "returns the newest price per ticker" do
      ticker = ticker_fixture(%{name: "Gold", symbol: "GC=F"})

      _older =
        ticker_price_fixture(%{
          ticker: ticker,
          price: "100.0",
          fetched_at: ~U[2026-03-22 09:33:00Z]
        })

      _newer =
        ticker_price_fixture(%{
          ticker: ticker,
          price: "125.0",
          fetched_at: ~U[2026-03-22 10:33:00Z]
        })

      latest_price =
        Enum.find(Markets.latest_prices(), fn price ->
          price.name == "Gold" and price.symbol == "GC=F" and price.ticker_id == ticker.id
        end)

      assert latest_price
      price = latest_price.price
      assert price == Decimal.new("125.0")
    end
  end
end
