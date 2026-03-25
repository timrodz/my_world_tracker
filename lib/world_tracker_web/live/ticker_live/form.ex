defmodule WorldTrackerWeb.TickerLive.Form do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Markets
  alias WorldTracker.Markets.Ticker
  alias WorldTracker.Sources

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Assign each ticker to the source responsible for its updates.</:subtitle>
      </.header>

      <.form for={@form} id="ticker-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:data_source_id]}
          type="select"
          label="Data Source"
          options={@data_source_options}
          prompt="Choose a data source"
        />
        <.input field={@form[:symbol]} type="text" label="Symbol" />
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." color="primary">Save Ticker</.button>
          <.button link_type="a" to={return_path(@return_to, @ticker)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:data_source_options, Sources.data_source_options(type: :markets))
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    ticker = Markets.get_ticker!(id)

    socket
    |> assign(:page_title, "Edit Ticker")
    |> assign(:ticker, ticker)
    |> assign(:form, to_form(Markets.change_ticker(ticker)))
  end

  defp apply_action(socket, :new, _params) do
    ticker = %Ticker{}

    socket
    |> assign(:page_title, "New Ticker")
    |> assign(:ticker, ticker)
    |> assign(:form, to_form(Markets.change_ticker(ticker)))
  end

  @impl true
  def handle_event("validate", %{"ticker" => ticker_params}, socket) do
    changeset = Markets.change_ticker(socket.assigns.ticker, ticker_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticker" => ticker_params}, socket) do
    save_ticker(socket, socket.assigns.live_action, ticker_params)
  end

  defp save_ticker(socket, :edit, ticker_params) do
    case Markets.update_ticker(socket.assigns.ticker, ticker_params) do
      {:ok, ticker} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticker updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, ticker))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ticker(socket, :new, ticker_params) do
    case Markets.create_ticker(ticker_params) do
      {:ok, ticker} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticker created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, ticker))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _ticker), do: ~p"/tickers"
  defp return_path("show", ticker), do: ~p"/tickers/#{ticker}"
end
