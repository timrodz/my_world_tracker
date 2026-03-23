defmodule WorldTracker.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries, primary_key: false) do
      add :alpha2, :string, primary_key: true
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
