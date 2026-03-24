defmodule WorldTrackerWeb.DataSourceLive.Show do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Sources

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@data_source.name}
        <:subtitle>Manage this source and review the tickers assigned to it.</:subtitle>
        <:actions>
          <.button navigate={~p"/data-sources"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/data-sources/#{@data_source}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Data Source
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@data_source.name}</:item>
        <:item title="Slug">{@data_source.slug}</:item>
        <:item title="Type">{data_source_type(@data_source.type)}</:item>
        <:item title="Base url">{@data_source.base_url}</:item>
        <:item title="Endpoint url">{@data_source.endpoint_url || "-"}</:item>
        <:item title="Tickers">{length(@data_source.tickers)}</:item>
      </.list>

      <section class="mt-8 rounded-3xl border border-base-300 bg-base-100 p-6 shadow-sm">
        <div class="mb-4 flex items-center justify-between gap-4">
          <div>
            <h2 class="text-lg font-semibold text-base-content">Assigned Tickers</h2>
            <p class="text-sm text-base-content/65">
              Each ticker inherits its update strategy from this source.
            </p>
          </div>
          <.button navigate={~p"/tickers/new"}>Add Ticker</.button>
        </div>

        <div
          :if={@data_source.tickers == []}
          class="rounded-2xl border border-dashed border-base-300 px-4 py-6 text-sm text-base-content/65"
        >
          No tickers are attached to this source yet.
        </div>

        <div :if={@data_source.tickers != []} class="grid gap-3 md:grid-cols-2">
          <.link
            :for={ticker <- @data_source.tickers}
            navigate={~p"/tickers/#{ticker}"}
            class="group rounded-2xl border border-base-300 bg-base-200/60 px-4 py-3 transition hover:-translate-y-0.5 hover:border-primary/40 hover:bg-base-200"
          >
            <div class="flex items-center justify-between gap-3">
              <div>
                <p class="font-semibold text-base-content">{ticker.name}</p>
                <p class="text-sm uppercase tracking-[0.18em] text-base-content/55">
                  {ticker.symbol}
                </p>
              </div>
              <.icon
                name="hero-arrow-up-right"
                class="size-5 text-base-content/35 transition group-hover:text-primary"
              />
            </div>
          </.link>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Data source")
     |> assign(:data_source, Sources.get_data_source!(id))}
  end

  defp data_source_type(nil), do: "-"
  defp data_source_type(type), do: type |> to_string() |> String.capitalize()
end
