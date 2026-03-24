defmodule WorldTracker.NewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldTracker.News` context.
  """

  import WorldTracker.SourcesFixtures

  @doc """
  Generate a news data_source for use in article fixtures.
  """
  def news_data_source_fixture(attrs \\ %{}) do
    data_source_fixture(
      Map.merge(
        %{
          type: :news,
          endpoint_url: "https://example.com/rss.xml"
        },
        attrs
      )
    )
  end

  @doc """
  Generate an article. Accepts `data_source_id` in attrs or creates one automatically.
  """
  def article_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)

    data_source_id =
      Map.get_lazy(attrs, :data_source_id, fn ->
        news_data_source_fixture().id
      end)

    {:ok, article} =
      attrs
      |> Map.delete(:data_source_id)
      |> Enum.into(%{
        data_source_id: data_source_id,
        author: "some author",
        categories: ["World", "Politics"],
        description: "some description",
        guid: "guid-#{System.unique_integer([:positive])}",
        image_url: "https://example.com/image.jpg",
        published_at: ~U[2026-03-23 08:50:00Z],
        title: "some title",
        url: "https://example.com/article"
      })
      |> WorldTracker.News.create_article()

    WorldTracker.News.get_article!(article.id)
  end
end
