defmodule WorldTracker.NewsTest do
  use WorldTracker.DataCase

  alias WorldTracker.News

  describe "news_articles" do
    alias WorldTracker.News.Article

    import WorldTracker.NewsFixtures

    @invalid_attrs %{data_source_id: nil, guid: nil, title: nil, url: nil}

    test "list_news_articles/0 returns all news_articles ordered by published_at desc" do
      article = article_fixture()
      listed = News.list_news_articles()
      assert Enum.any?(listed, &(&1.id == article.id))
    end

    test "list_news_articles/1 filters by source slug" do
      ds = news_data_source_fixture()
      article = article_fixture(data_source_id: ds.id)

      results = News.list_news_articles(source: ds.slug)
      assert Enum.any?(results, &(&1.id == article.id))
    end

    test "list_news_articles/1 preloads data_source" do
      article_fixture()
      [article | _] = News.list_news_articles()
      assert %WorldTracker.Sources.DataSource{} = article.data_source
    end

    test "get_article!/1 returns the article with given id and preloads data_source" do
      article = article_fixture()
      fetched = News.get_article!(article.id)
      assert fetched.id == article.id
      assert %WorldTracker.Sources.DataSource{} = fetched.data_source
    end

    test "create_article/1 with valid data creates an article" do
      ds = news_data_source_fixture()

      valid_attrs = %{
        data_source_id: ds.id,
        guid: "unique-guid-1",
        title: "some title",
        url: "https://example.com/article",
        description: "some description",
        author: "some author",
        categories: ["Tech", "World"],
        image_url: "https://example.com/image.jpg",
        published_at: ~U[2026-03-23 08:50:00Z]
      }

      assert {:ok, %Article{} = article} = News.create_article(valid_attrs)
      assert article.title == "some title"
      assert article.guid == "unique-guid-1"
      assert article.categories == ["Tech", "World"]
      assert article.data_source_id == ds.id
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = News.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()

      update_attrs = %{
        title: "updated title",
        description: "updated description",
        url: "https://example.com/updated"
      }

      assert {:ok, %Article{} = updated} = News.update_article(article, update_attrs)
      assert updated.title == "updated title"
      assert updated.description == "updated description"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = News.update_article(article, %{title: nil})
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = News.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> News.get_article!(article.id) end
    end

    test "change_article/1 returns an article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = News.change_article(article)
    end

    test "upsert_articles/1 inserts new articles and skips duplicates" do
      ds = news_data_source_fixture()
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      rows = [
        %{
          data_source_id: ds.id,
          guid: "upsert-guid-1",
          title: "First",
          url: "https://example.com/1",
          categories: [],
          inserted_at: now,
          updated_at: now
        },
        %{
          data_source_id: ds.id,
          guid: "upsert-guid-2",
          title: "Second",
          url: "https://example.com/2",
          categories: [],
          inserted_at: now,
          updated_at: now
        }
      ]

      assert News.upsert_articles(rows) == 2
      # Second call should insert 0 (duplicates skipped)
      assert News.upsert_articles(rows) == 0
    end
  end
end
