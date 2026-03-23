defmodule WorldTracker.Markets do
  @moduledoc """
  The Markets context.
  """

  import Ecto.Query, warn: false
  alias WorldTracker.Repo

  alias WorldTracker.Markets.Ticker
  alias WorldTracker.Markets.TickerPrice

  @doc """
  Returns the list of tickers.

  ## Examples

      iex> list_tickers()
      [%Ticker{}, ...]

  """
  def list_tickers do
    Repo.all(
      from ticker in Ticker,
        join: data_source in assoc(ticker, :data_source),
        preload: [data_source: data_source],
        order_by: [asc: data_source.name, asc: ticker.name]
    )
  end

  @doc """
  Gets a single ticker.

  Raises `Ecto.NoResultsError` if the Ticker does not exist.

  ## Examples

      iex> get_ticker!(123)
      %Ticker{}

      iex> get_ticker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticker!(id) do
    Repo.get!(Ticker, id)
    |> Repo.preload([
      :data_source,
      ticker_prices: from(price in TickerPrice, order_by: [desc: price.fetched_at], limit: 10)
    ])
  end

  @doc """
  Creates a ticker.

  ## Examples

      iex> create_ticker(%{field: value})
      {:ok, %Ticker{}}

      iex> create_ticker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticker(attrs) do
    %Ticker{}
    |> Ticker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticker.

  ## Examples

      iex> update_ticker(ticker, %{field: new_value})
      {:ok, %Ticker{}}

      iex> update_ticker(ticker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticker(%Ticker{} = ticker, attrs) do
    ticker
    |> Ticker.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticker.

  ## Examples

      iex> delete_ticker(ticker)
      {:ok, %Ticker{}}

      iex> delete_ticker(ticker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticker(%Ticker{} = ticker) do
    Repo.delete(ticker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticker changes.

  ## Examples

      iex> change_ticker(ticker)
      %Ecto.Changeset{data: %Ticker{}}

  """
  def change_ticker(%Ticker{} = ticker, attrs \\ %{}) do
    Ticker.changeset(ticker, attrs)
  end

  @doc """
  Returns the list of ticker_prices.

  ## Examples

      iex> list_ticker_prices()
      [%TickerPrice{}, ...]

  """
  def list_ticker_prices do
    Repo.all(from ticker_price in TickerPrice, preload: [ticker: :data_source])
  end

  @doc """
  Gets a single ticker_price.

  Raises `Ecto.NoResultsError` if the Ticker price does not exist.

  ## Examples

      iex> get_ticker_price!(123)
      %TickerPrice{}

      iex> get_ticker_price!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticker_price!(id) do
    Repo.get!(TickerPrice, id)
    |> Repo.preload(ticker: :data_source)
  end

  @doc """
  Creates a ticker_price.

  ## Examples

      iex> create_ticker_price(%{field: value})
      {:ok, %TickerPrice{}}

      iex> create_ticker_price(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticker_price(attrs) do
    %TickerPrice{}
    |> TickerPrice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticker_price.

  ## Examples

      iex> update_ticker_price(ticker_price, %{field: new_value})
      {:ok, %TickerPrice{}}

      iex> update_ticker_price(ticker_price, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticker_price(%TickerPrice{} = ticker_price, attrs) do
    ticker_price
    |> TickerPrice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticker_price.

  ## Examples

      iex> delete_ticker_price(ticker_price)
      {:ok, %TickerPrice{}}

      iex> delete_ticker_price(ticker_price)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticker_price(%TickerPrice{} = ticker_price) do
    Repo.delete(ticker_price)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticker_price changes.

  ## Examples

      iex> change_ticker_price(ticker_price)
      %Ecto.Changeset{data: %TickerPrice{}}

  """
  def change_ticker_price(%TickerPrice{} = ticker_price, attrs \\ %{}) do
    TickerPrice.changeset(ticker_price, attrs)
  end

  def list_tickers_grouped_by_source do
    list_tickers()
    |> Enum.group_by(& &1.data_source.slug)
  end

  def latest_prices do
    latest_price_query =
      from ticker_price in TickerPrice,
        distinct: ticker_price.ticker_id,
        order_by: [asc: ticker_price.ticker_id, desc: ticker_price.fetched_at]

    Repo.all(
      from ticker_price in subquery(latest_price_query),
        join: ticker in Ticker,
        on: ticker.id == ticker_price.ticker_id,
        join: data_source in assoc(ticker, :data_source),
        select: %{
          ticker_id: ticker.id,
          symbol: ticker.symbol,
          name: ticker.name,
          data_source_name: data_source.name,
          data_source_slug: data_source.slug,
          price: ticker_price.price,
          fetched_at: ticker_price.fetched_at
        },
        order_by: [asc: data_source.name, asc: ticker.name]
    )
  end

  def ticker_history(ticker_id, limit \\ 60) do
    Repo.all(
      from ticker_price in TickerPrice,
        where: ticker_price.ticker_id == ^ticker_id,
        order_by: [desc: ticker_price.fetched_at],
        limit: ^limit,
        preload: [ticker: :data_source]
    )
  end

  def record_price(%Ticker{} = ticker, attrs) do
    attrs = Map.put(attrs, :ticker_id, ticker.id)
    create_ticker_price(attrs)
  end

  def prune_prices_older_than(cutoff) do
    from(ticker_price in TickerPrice, where: ticker_price.fetched_at < ^cutoff)
    |> Repo.delete_all()
  end
end
