defmodule WorldTracker.Repo.Migrations.CreateDataSources do
  use Ecto.Migration

  def change do
    create table(:data_sources) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :base_url, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:data_sources, [:slug])
  end
end
