defmodule WorldTracker.Workers.Locations do
  use Oban.Worker, queue: :locations, max_attempts: 1

  require Logger

  alias Oban.Job
  alias Phoenix.PubSub
  alias WorldTracker.Locations
  alias WorldTracker.Locations.OverpassClient

  @location_types [:data_center, :oil_facility, :port, :airport, :military_base]

  def enqueue(attrs \\ %{}) do
    Logger.debug("enqueueing locations polling job attrs=#{inspect(attrs)}")

    attrs
    |> new()
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Job{id: job_id, queue: queue, args: args}) do
    started_at = System.monotonic_time(:millisecond)

    Logger.debug(
      "starting locations polling job_id=#{job_id} queue=#{queue} args=#{inspect(args)}"
    )

    stats = poll_locations()

    duration_ms = System.monotonic_time(:millisecond) - started_at

    Logger.debug(
      "completed locations polling job_id=#{job_id} queue=#{queue} types=#{stats.types} fetched=#{stats.fetched} stored=#{stats.stored} broadcasts=#{stats.broadcasts} duration_ms=#{duration_ms}"
    )

    :ok
  rescue
    error ->
      Logger.error("locations polling failed job_id=#{job_id}: #{Exception.message(error)}")
      :ok
  end

  defp poll_locations do
    Enum.reduce(@location_types, %{types: 0, fetched: 0, stored: 0, broadcasts: 0}, fn type,
                                                                                       acc ->
      stats = poll_type(type)

      %{
        types: acc.types + 1,
        fetched: acc.fetched + stats.fetched,
        stored: acc.stored + stats.stored,
        broadcasts: acc.broadcasts + stats.broadcasts
      }
    end)
  end

  defp poll_type(type) do
    Logger.debug("polling locations type=#{type}")

    with {:ok, locations} <- overpass_client().fetch_locations(type),
         {:ok, stored_count} <- Locations.replace_locations_by_type(type, locations) do
      Logger.debug("broadcasting location updates type=#{type} stored=#{stored_count}")
      PubSub.broadcast(WorldTracker.PubSub, Locations.topic(), {:locations_updated, type})

      %{
        fetched: length(locations),
        stored: stored_count,
        broadcasts: 1
      }
    else
      {:error, reason} ->
        Logger.error("failed polling locations type=#{type}: #{inspect(reason)}")
        %{fetched: 0, stored: 0, broadcasts: 0}
    end
  end

  defp overpass_client do
    Application.get_env(:world_tracker, :overpass_client, OverpassClient)
  end
end
