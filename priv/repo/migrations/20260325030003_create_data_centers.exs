defmodule WorldTracker.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :subtype, :string
      add :operator, :string
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :city, :string
      add :country_id, references(:countries, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:locations, [:type])
    create index(:locations, [:country_id])
  end
end
