defmodule WorldTrackerWeb.DataSourceLive.Form do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Sources
  alias WorldTracker.Sources.DataSource

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage data_source records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="data_source-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:base_url]} type="text" label="Base url" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Data source</.button>
          <.button navigate={return_path(@return_to, @data_source)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    data_source = Sources.get_data_source!(id)

    socket
    |> assign(:page_title, "Edit Data source")
    |> assign(:data_source, data_source)
    |> assign(:form, to_form(Sources.change_data_source(data_source)))
  end

  defp apply_action(socket, :new, _params) do
    data_source = %DataSource{}

    socket
    |> assign(:page_title, "New Data source")
    |> assign(:data_source, data_source)
    |> assign(:form, to_form(Sources.change_data_source(data_source)))
  end

  @impl true
  def handle_event("validate", %{"data_source" => data_source_params}, socket) do
    changeset = Sources.change_data_source(socket.assigns.data_source, data_source_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"data_source" => data_source_params}, socket) do
    save_data_source(socket, socket.assigns.live_action, data_source_params)
  end

  defp save_data_source(socket, :edit, data_source_params) do
    case Sources.update_data_source(socket.assigns.data_source, data_source_params) do
      {:ok, data_source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Data source updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, data_source))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_data_source(socket, :new, data_source_params) do
    case Sources.create_data_source(data_source_params) do
      {:ok, data_source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Data source created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, data_source))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _data_source), do: ~p"/data-sources"
  defp return_path("show", data_source), do: ~p"/data-sources/#{data_source}"
end
