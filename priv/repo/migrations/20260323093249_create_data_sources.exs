defmodule WorldTracker.Repo.Migrations.CreateDataSources do
  use Ecto.Migration

  def change do
    execute("CREATE TYPE data_source_type AS ENUM ('markets', 'news', 'locations')")

    create table(:data_sources) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :base_url, :string, null: false
      add :type, :data_source_type, null: true
      add :endpoint_url, :string, null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:data_sources, [:slug])
  end
end
