defmodule WorldTracker.Locations do
  @moduledoc """
  The Locations context - tracks static global infrastructure locations.
  """

  import Ecto.Query, warn: false

  alias WorldTracker.Repo
  alias WorldTracker.Locations.Location

  @topic "locations"

  def topic, do: @topic

  @doc """
  Returns all locations ordered by type then name, with country preloaded.
  """
  def list_locations do
    Location
    |> order_by([l], asc: l.type, asc: l.name)
    |> preload(:country)
    |> Repo.all()
  end

  @doc """
  Returns all locations of the given type, ordered by name.
  """
  def list_locations_by_type(type)
      when type in [:data_center, :oil_facility, :port, :airport, :military_base] do
    Location
    |> where([l], l.type == ^type)
    |> order_by([l], asc: l.name)
    |> preload(:country)
    |> Repo.all()
  end

  @doc """
  Returns all data centers (type = :data_center) ordered by operator then name.
  """
  def list_data_centers do
    Location
    |> where([l], l.type == :data_center)
    |> order_by([l], asc: l.operator, asc: l.name)
    |> preload(:country)
    |> Repo.all()
  end

  @doc """
  Returns all oil facilities (type = :oil_facility) ordered by subtype then name.
  """
  def list_oil_facilities do
    Location
    |> where([l], l.type == :oil_facility)
    |> order_by([l], asc: l.subtype, asc: l.name)
    |> preload(:country)
    |> Repo.all()
  end

  @doc """
  Returns all ports ordered by name.
  """
  def list_ports do
    list_locations_by_type(:port)
  end

  @doc """
  Returns all airports ordered by name.
  """
  def list_airports do
    list_locations_by_type(:airport)
  end

  @doc """
  Returns all military bases ordered by name.
  """
  def list_military_bases do
    list_locations_by_type(:military_base)
  end

  @doc """
  Replaces all locations for a given type with the provided list.
  """
  def replace_locations_by_type(type, attrs_list)
      when type in [:data_center, :oil_facility, :port, :airport, :military_base] and
             is_list(attrs_list) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.transaction(fn ->
      from(l in Location, where: l.type == ^type)
      |> Repo.delete_all()

      rows =
        attrs_list
        |> Enum.map(fn attrs ->
          attrs
          |> Map.put(:type, type)
          |> Map.put(:inserted_at, now)
          |> Map.put(:updated_at, now)
          |> Map.take([
            :name,
            :type,
            :subtype,
            :operator,
            :latitude,
            :longitude,
            :city,
            :country_id,
            :inserted_at,
            :updated_at
          ])
        end)

      {count, _} =
        if rows == [] do
          {0, nil}
        else
          Repo.insert_all(Location, rows)
        end

      count
    end)
  end

  @doc """
  Returns data centers grouped by operator.
  """
  def list_data_centers_by_operator do
    list_data_centers()
    |> Enum.group_by(& &1.operator)
  end

  @doc """
  Returns oil facilities grouped by subtype.
  """
  def list_oil_facilities_by_type do
    list_oil_facilities()
    |> Enum.group_by(& &1.subtype)
  end
end
