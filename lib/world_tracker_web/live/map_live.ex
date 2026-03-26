defmodule WorldTrackerWeb.MapLive do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Locations
  alias WorldTracker.Shipping

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WorldTracker.PubSub, Shipping.topic())
    end

    ships = Shipping.list_ships(limit: 500)
    data_centers = Locations.list_data_centers()
    oil_facilities = Locations.list_oil_facilities()

    {:ok,
     socket
     |> assign(:page_title, "World Map")
     |> assign(:ships, ships)
     |> assign(:data_centers, data_centers)
     |> assign(:oil_facilities, oil_facilities)
     |> assign(:ship_count, length(ships))
     |> assign(:dc_count, length(data_centers))
     |> assign(:oil_count, length(oil_facilities))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <%!-- Hero --%>
      <section class="relative overflow-hidden rounded-[2rem] border border-base-300 bg-[radial-gradient(circle_at_top_left,_rgba(34,197,94,0.18),_transparent_36%),linear-gradient(135deg,_rgba(15,23,42,0.98),_rgba(20,30,48,0.94))] px-6 py-8 text-base-100 shadow-2xl shadow-slate-950/15 sm:px-10">
        <div class="relative flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div class="max-w-2xl space-y-3">
            <p class="text-xs font-semibold uppercase tracking-[0.35em] text-green-300/80">
              World Tracker · Live Map
            </p>
            <h1 class="font-serif text-3xl leading-tight text-white sm:text-4xl">
              Global infrastructure at a glance.
            </h1>
            <p class="text-sm leading-7 text-slate-200/70">
              Live vessel positions from AISStream, cloud data centers, and major oil &amp; energy facilities plotted on a single interactive map.
            </p>
          </div>

          <div class="grid grid-cols-3 gap-2 rounded-[1.75rem] border border-white/10 bg-white/8 p-4 text-center text-sm backdrop-blur">
            <div class="px-4">
              <p class="text-2xl font-bold text-green-400">{@ship_count}</p>
              <p class="mt-1 text-xs uppercase tracking-wide text-slate-300">Ships</p>
            </div>
            <div class="border-x border-white/10 px-4">
              <p class="text-2xl font-bold text-blue-400">{@dc_count}</p>
              <p class="mt-1 text-xs uppercase tracking-wide text-slate-300">Data Centers</p>
            </div>
            <div class="px-4">
              <p class="text-2xl font-bold text-orange-400">{@oil_count}</p>
              <p class="mt-1 text-xs uppercase tracking-wide text-slate-300">Oil Facilities</p>
            </div>
          </div>
        </div>
      </section>

      <%!-- Legend --%>
      <div class="flex flex-wrap gap-4 text-sm text-base-content/70">
        <div class="flex items-center gap-2">
          <span class="inline-block h-3 w-3 rounded-full bg-green-500 border border-white/40"></span>
          Ships (live)
        </div>
        <div class="flex items-center gap-2">
          <span class="inline-block h-3 w-3 rounded-sm bg-blue-500 border border-white/40"></span>
          Data Centers
        </div>
        <div class="flex items-center gap-2">
          <span class="inline-block h-3 w-3 rounded-full bg-orange-500 border border-white/40"></span>
          Oil Facilities
        </div>
        <p class="ml-auto text-xs text-base-content/40">
          Use the layer control (top-right of map) to toggle layers
        </p>
      </div>

      <%!-- Map --%>
      <div
        id="world-map"
        phx-hook="WorldMap"
        phx-update="ignore"
        data-ships={Jason.encode!(Enum.map(@ships, &ship_json/1))}
        data-data-centers={Jason.encode!(Enum.map(@data_centers, &dc_json/1))}
        data-oil-facilities={Jason.encode!(Enum.map(@oil_facilities, &oil_json/1))}
        class="h-[65vh] min-h-[400px] w-full rounded-sm overflow-hidden border border-base-300 shadow-lg"
      />
    </Layouts.app>
    """
  end

  @impl true
  def handle_info({:ship_updated, ship}, socket) do
    {:noreply, push_event(socket, "ship-updated", ship_json(ship))}
  end

  defp ship_json(ship) do
    %{
      mmsi: ship.mmsi,
      name: ship.name,
      latitude: ship.latitude,
      longitude: ship.longitude,
      speed: ship.speed,
      course: ship.course,
      flag: ship.flag,
      destination: ship.destination
    }
  end

  defp dc_json(dc) do
    %{
      id: dc.id,
      name: dc.name,
      operator: dc.operator,
      latitude: dc.latitude,
      longitude: dc.longitude,
      city: dc.city,
      country_code: get_alpha2(dc.country)
    }
  end

  defp oil_json(oil) do
    %{
      id: oil.id,
      name: oil.name,
      facility_type: oil.subtype,
      latitude: oil.latitude,
      longitude: oil.longitude,
      country_code: get_alpha2(oil.country),
      operator: oil.operator
    }
  end

  defp get_alpha2(nil), do: nil
  defp get_alpha2(%{alpha2_code: code}), do: code
  defp get_alpha2(_), do: nil
end
