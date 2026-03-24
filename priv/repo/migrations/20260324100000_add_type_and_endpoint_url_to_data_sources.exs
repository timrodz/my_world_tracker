defmodule WorldTracker.Repo.Migrations.AddTypeAndEndpointUrlToDataSources do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE data_source_type AS ENUM ('markets', 'news')")

    alter table(:data_sources) do
      add :type, :data_source_type, null: true
      add :endpoint_url, :string, null: true
    end
  end

  def down do
    alter table(:data_sources) do
      remove :endpoint_url
      remove :type
    end

    execute("DROP TYPE data_source_type")
  end
end
