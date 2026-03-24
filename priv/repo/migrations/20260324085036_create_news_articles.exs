defmodule WorldTracker.Repo.Migrations.CreateNewsArticles do
  use Ecto.Migration

  def change do
    create table(:news_articles) do
      add :data_source_id, references(:data_sources, on_delete: :delete_all), null: false
      add :guid, :string, null: false
      add :title, :string, null: false
      add :description, :text
      add :url, :string, null: false
      add :image_url, :string
      add :author, :string
      add :categories, {:array, :string}, default: []
      add :published_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:news_articles, [:data_source_id, :guid])
    create index(:news_articles, [:published_at])
    create index(:news_articles, [:data_source_id])
  end
end
