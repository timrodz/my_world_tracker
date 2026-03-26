defmodule WorldTracker.Repo.Migrations.CreateShips do
  use Ecto.Migration

  def change do
    create table(:ships) do
      add :mmsi, :integer, null: false
      add :name, :string
      add :latitude, :float
      add :longitude, :float
      add :speed, :float
      add :course, :float
      add :ship_type, :integer
      add :flag, :string
      add :destination, :string
      add :last_seen_at, :utc_datetime
      add :data_source_id, references(:data_sources, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ships, [:mmsi])
    create index(:ships, [:data_source_id])
  end
end
