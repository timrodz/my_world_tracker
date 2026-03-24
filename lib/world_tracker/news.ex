defmodule WorldTracker.News do
  @moduledoc """
  The News context.
  """

  import Ecto.Query, warn: false
  alias WorldTracker.Repo

  alias WorldTracker.News.Article

  @topic "news_articles"

  def topic, do: @topic

  @doc """
  Returns the list of news_articles, ordered by most recent first,
  optionally filtered by data_source slug.
  """
  def list_news_articles(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    source_slug = Keyword.get(opts, :source)

    Article
    |> join(:inner, [a], ds in assoc(a, :data_source))
    |> then(fn q ->
      if source_slug do
        where(q, [a, ds], ds.slug == ^source_slug)
      else
        q
      end
    end)
    |> order_by([a], desc_nulls_last: a.published_at, desc: a.inserted_at)
    |> limit(^limit)
    |> preload(:data_source)
    |> Repo.all()
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.
  """
  def get_article!(id), do: Repo.get!(Article, id) |> Repo.preload(:data_source)

  @doc """
  Creates an article.
  """
  def create_article(attrs) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Bulk-inserts a list of article attribute maps, skipping duplicates
  (conflict on data_source_id + guid). Returns the count of newly inserted rows.
  """
  def upsert_articles(articles) when is_list(articles) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(articles, fn attrs ->
        attrs
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    {count, _} =
      Repo.insert_all(
        Article,
        rows,
        on_conflict: :nothing,
        conflict_target: [:data_source_id, :guid]
      )

    count
  end

  @doc """
  Updates an article.
  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an article.
  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.
  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end
end
