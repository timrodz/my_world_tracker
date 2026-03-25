defmodule WorldTracker.Infrastructure do
  @moduledoc """
  The Infrastructure context — tracks static global infrastructure:
  cloud data centers and oil/energy facilities.
  """

  import Ecto.Query, warn: false

  alias WorldTracker.Repo
  alias WorldTracker.Infrastructure.DataCenter
  alias WorldTracker.Infrastructure.OilFacility

  @doc """
  Returns all data centers ordered by operator then name.
  """
  def list_data_centers do
    DataCenter
    |> order_by([dc], asc: dc.operator, asc: dc.name)
    |> Repo.all()
  end

  @doc """
  Returns all oil facilities ordered by facility_type then name.
  """
  def list_oil_facilities do
    OilFacility
    |> order_by([f], asc: f.facility_type, asc: f.name)
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
  Returns oil facilities grouped by facility_type.
  """
  def list_oil_facilities_by_type do
    list_oil_facilities()
    |> Enum.group_by(& &1.facility_type)
  end
end
