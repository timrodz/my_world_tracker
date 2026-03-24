defmodule WorldTrackerWeb.ArticleLive.Show do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.News

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Article {@article.id}
        <:subtitle>This is a article record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/news-articles"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/news-articles/#{@article}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit article
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Guid">{@article.guid}</:item>
        <:item title="Title">{@article.title}</:item>
        <:item title="Description">{@article.description}</:item>
        <:item title="Url">{@article.url}</:item>
        <:item title="Image url">{@article.image_url}</:item>
        <:item title="Author">{@article.author}</:item>
        <:item title="Published at">{@article.published_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Article")
     |> assign(:article, News.get_article!(id))}
  end
end
