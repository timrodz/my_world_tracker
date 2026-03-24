defmodule WorldTrackerWeb.ArticleLive.Form do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.News
  alias WorldTracker.News.Article

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage article records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="article-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:guid]} type="text" label="Guid" />
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:image_url]} type="text" label="Image url" />
        <.input field={@form[:author]} type="text" label="Author" />
        <.input field={@form[:published_at]} type="datetime-local" label="Published at" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Article</.button>
          <.button navigate={return_path(@return_to, @article)}>Cancel</.button>
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
    article = News.get_article!(id)

    socket
    |> assign(:page_title, "Edit Article")
    |> assign(:article, article)
    |> assign(:form, to_form(News.change_article(article)))
  end

  defp apply_action(socket, :new, _params) do
    article = %Article{}

    socket
    |> assign(:page_title, "New Article")
    |> assign(:article, article)
    |> assign(:form, to_form(News.change_article(article)))
  end

  @impl true
  def handle_event("validate", %{"article" => article_params}, socket) do
    changeset = News.change_article(socket.assigns.article, article_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"article" => article_params}, socket) do
    save_article(socket, socket.assigns.live_action, article_params)
  end

  defp save_article(socket, :edit, article_params) do
    case News.update_article(socket.assigns.article, article_params) do
      {:ok, article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, article))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_article(socket, :new, article_params) do
    case News.create_article(article_params) do
      {:ok, article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, article))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _article), do: ~p"/news-articles"
  defp return_path("show", article), do: ~p"/news-articles/#{article}"
end
