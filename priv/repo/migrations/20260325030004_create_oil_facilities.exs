defmodule WorldTracker.Repo.Migrations.CreateOilFacilities do
  use Ecto.Migration

  def change do
    create table(:oil_facilities) do
      add :name, :string, null: false
      add :facility_type, :string, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :country_code, references(:countries, column: :alpha2, type: :string)
      add :operator, :string

      timestamps(type: :utc_datetime)
    end

    create index(:oil_facilities, [:facility_type])
    create index(:oil_facilities, [:country_code])
  end
end
