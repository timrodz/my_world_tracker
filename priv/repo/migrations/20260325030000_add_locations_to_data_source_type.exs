defmodule WorldTracker.Repo.Migrations.AddLocationsToDataSourceType do
  use Ecto.Migration

  def up do
    execute("ALTER TYPE data_source_type ADD VALUE IF NOT EXISTS 'locations'")
  end

  def down do
    # PostgreSQL does not support removing enum values; this is a no-op.
    :ok
  end
end
