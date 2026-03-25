defmodule WorldTracker.Repo.Migrations.CreateDataCenters do
  use Ecto.Migration

  def change do
    create table(:data_centers) do
      add :name, :string, null: false
      add :operator, :string, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :city, :string
      add :country_code, :string

      timestamps(type: :utc_datetime)
    end

    create index(:data_centers, [:operator])
    create index(:data_centers, [:country_code])
  end
end
