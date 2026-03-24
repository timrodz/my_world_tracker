defmodule WorldTracker.Repo.Migrations.SeedNewsDataSources do
  use Ecto.Migration

  import Ecto.Query

  @news_sources [
    %{name: "BBC News", slug: "bbc_news", base_url: "https://feeds.bbci.co.uk"},
    %{name: "Al Jazeera", slug: "al_jazeera", base_url: "https://www.aljazeera.com"},
    %{name: "The Guardian", slug: "the_guardian", base_url: "https://www.theguardian.com"},
    %{name: "NPR World", slug: "npr_world", base_url: "https://feeds.npr.org"}
  ]

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(@news_sources, &Map.merge(&1, %{inserted_at: now, updated_at: now}))

    repo().insert_all(
      "data_sources",
      rows,
      on_conflict: :nothing,
      conflict_target: [:slug]
    )
  end

  def down do
    slugs = Enum.map(@news_sources, & &1.slug)
    repo().delete_all(from(ds in "data_sources", where: ds.slug in ^slugs))
  end
end
