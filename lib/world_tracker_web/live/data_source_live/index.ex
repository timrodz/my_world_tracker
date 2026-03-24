defmodule WorldTrackerWeb.DataSourceLive.Index do
  alias Phoenix.Endpoint
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Sources

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Data Sources
        <:actions>
          <.button variant="primary" navigate={~p"/data-sources/new"}>
            <.icon name="hero-plus" /> New Data Source
          </.button>
        </:actions>
      </.header>

      <.table
        id="data_sources"
        rows={@streams.data_sources}
        row_click={fn {_id, data_source} -> JS.navigate(~p"/data-sources/#{data_source}") end}
      >
        <:col :let={{_id, data_source}} label="Name">{data_source.name}</:col>
        <:col :let={{_id, data_source}} label="Slug">{data_source.slug}</:col>
        <:col :let={{_id, data_source}} label="Base url">{data_source.base_url}</:col>
        <:col :let={{_id, data_source}} label="Endpoint url">{data_source.endpoint_url}</:col>
        <:action :let={{_id, data_source}}>
          <div class="sr-only">
            <.link navigate={~p"/data-sources/#{data_source}"}>Show</.link>
          </div>
          <.link navigate={~p"/data-sources/#{data_source}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, data_source}}>
          <.link
            phx-click={JS.push("delete", value: %{id: data_source.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Data Sources")
     |> stream(:data_sources, list_data_sources())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    data_source = Sources.get_data_source!(id)
    {:ok, _} = Sources.delete_data_source(data_source)

    {:noreply, stream_delete(socket, :data_sources, data_source)}
  end

  defp list_data_sources() do
    Sources.list_data_sources()
  end
end
