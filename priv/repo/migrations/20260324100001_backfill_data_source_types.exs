defmodule WorldTracker.Repo.Migrations.BackfillDataSourceTypes do
  use Ecto.Migration

  import Ecto.Query

  @markets_slugs ["yahoo_finance"]

  @news_sources [
    %{slug: "bbc_news", endpoint_url: "https://feeds.bbci.co.uk/news/world/rss.xml"},
    %{slug: "al_jazeera", endpoint_url: "https://www.aljazeera.com/xml/rss/all.xml"},
    %{slug: "the_guardian", endpoint_url: "https://www.theguardian.com/world/rss"},
    %{slug: "npr_world", endpoint_url: "https://feeds.npr.org/1004/rss.xml"}
  ]

  def up do
    repo().update_all(
      from(ds in "data_sources", where: ds.slug in ^@markets_slugs),
      set: [type: "markets"]
    )

    for %{slug: slug, endpoint_url: url} <- @news_sources do
      repo().update_all(
        from(ds in "data_sources", where: ds.slug == ^slug),
        set: [type: "news", endpoint_url: url]
      )
    end
  end

  def down do
    all_slugs = @markets_slugs ++ Enum.map(@news_sources, & &1.slug)

    repo().update_all(
      from(ds in "data_sources", where: ds.slug in ^all_slugs),
      set: [type: nil, endpoint_url: nil]
    )
  end
end
