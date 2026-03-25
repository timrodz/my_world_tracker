defmodule WorldTracker.Infrastructure do
  @moduledoc """
  The Infrastructure context — tracks static global infrastructure locations:
  cloud data centers and oil/energy facilities, stored in a unified `locations`
  table differentiated by `type` (:data_center | :oil_facility).
  """

  import Ecto.Query, warn: false

  alias WorldTracker.Repo
  alias WorldTracker.Infrastructure.Location

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
  def list_locations_by_type(type) when type in [:data_center, :oil_facility] do
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
