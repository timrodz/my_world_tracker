defmodule WorldTracker.Repo.Migrations.CreateTickers do
  use Ecto.Migration

  def change do
    create table(:tickers) do
      add :symbol, :string, null: false
      add :name, :string, null: false
      add :data_source_id, references(:data_sources, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tickers, [:data_source_id])
    create unique_index(:tickers, [:data_source_id, :symbol])
  end
end
