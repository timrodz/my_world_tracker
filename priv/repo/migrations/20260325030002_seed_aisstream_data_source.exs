defmodule WorldTracker.Repo.Migrations.SeedAisstreamDataSource do
  use Ecto.Migration

  import Ecto.Query

  @slug "aisstream"

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    repo().insert_all(
      "data_sources",
      [
        %{
          name: "AISStream",
          slug: @slug,
          base_url: "wss://stream.aisstream.io",
          type: "locations",
          endpoint_url: "/v0/stream",
          inserted_at: now,
          updated_at: now
        }
      ],
      on_conflict: :nothing,
      conflict_target: [:slug]
    )
  end

  def down do
    repo().delete_all(from(ds in "data_sources", where: ds.slug == @slug))
  end
end
