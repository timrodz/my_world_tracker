defmodule WorldTracker.Shipping do
  @moduledoc """
  The Shipping context — tracks vessel positions from AIS data sources.
  """

  import Ecto.Query, warn: false

  alias WorldTracker.Repo
  alias WorldTracker.Shipping.Ship
  alias WorldTracker.Sources.DataSource

  @topic "ships"

  def topic, do: @topic

  @doc """
  Returns ships ordered by last_seen_at descending.
  Accepts `limit:` option to cap results (default: all).
  """
  def list_ships(opts \\ []) do
    limit = Keyword.get(opts, :limit)

    Ship
    |> order_by([s], desc_nulls_last: s.last_seen_at)
    |> then(fn q -> if limit, do: limit(q, ^limit), else: q end)
    |> Repo.all()
  end

  @doc """
  Returns the AISStream `%DataSource{}`, or `nil` if not seeded yet.
  """
  def get_aisstream_data_source do
    Repo.one(
      from(ds in DataSource,
        where: ds.slug == "aisstream" and ds.type == :locations
      )
    )
  end

  @doc """
  Upserts a ship by MMSI. On conflict, only updates fields that are non-NULL
  in the incoming data, preserving existing values otherwise.
  Returns `{:ok, ship}` or `{:error, changeset}`.
  """
  def upsert_ship(attrs) when is_map(attrs) do
    %Ship{}
    |> Ship.changeset(attrs)
    |> Repo.insert(
      on_conflict: [
        set: [
          name: fragment("COALESCE(EXCLUDED.name, ships.name)"),
          latitude: fragment("COALESCE(EXCLUDED.latitude, ships.latitude)"),
          longitude: fragment("COALESCE(EXCLUDED.longitude, ships.longitude)"),
          speed: fragment("COALESCE(EXCLUDED.speed, ships.speed)"),
          course: fragment("COALESCE(EXCLUDED.course, ships.course)"),
          ship_type: fragment("COALESCE(EXCLUDED.ship_type, ships.ship_type)"),
          flag: fragment("COALESCE(EXCLUDED.flag, ships.flag)"),
          destination: fragment("COALESCE(EXCLUDED.destination, ships.destination)"),
          last_seen_at: fragment("COALESCE(EXCLUDED.last_seen_at, ships.last_seen_at)"),
          updated_at: fragment("EXCLUDED.updated_at")
        ]
      ],
      conflict_target: :mmsi,
      returning: true
    )
  end
end
