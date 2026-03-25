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
    mmsi = Map.get(attrs, :mmsi) || Map.get(attrs, "mmsi")

    case mmsi do
      nil ->
        %Ship{}
        |> Ship.changeset(attrs)
        |> Repo.insert()

      mmsi ->
        case Repo.get_by(Ship, mmsi: mmsi) do
          nil ->
            %Ship{}
            |> Ship.changeset(attrs)
            |> Repo.insert()

          existing ->
            merged_attrs = merge_ship_attrs(existing, attrs)

            existing
            |> Ship.changeset(merged_attrs)
            |> Repo.update()
        end
    end
  end

  defp merge_ship_attrs(existing, attrs) when is_map(attrs) do
    get = fn key ->
      cond do
        Map.has_key?(attrs, key) -> Map.get(attrs, key)
        Map.has_key?(attrs, to_string(key)) -> Map.get(attrs, to_string(key))
        true -> Map.get(existing, key)
      end
    end

    %{
      mmsi: existing.mmsi,
      data_source_id: existing.data_source_id,
      name: get.(:name),
      latitude: get.(:latitude),
      longitude: get.(:longitude),
      speed: get.(:speed),
      course: get.(:course),
      ship_type: get.(:ship_type),
      flag: get.(:flag),
      destination: get.(:destination),
      last_seen_at: get.(:last_seen_at)
    }
  end
end
