defmodule WorldTracker.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:country_codes) do
      add :country_id, references(:countries, on_delete: :delete_all), null: false
      add :alpha2_code, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:country_codes, [:country_id])
    create unique_index(:country_codes, [:alpha2_code])
  end
end
