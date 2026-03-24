defmodule WorldTracker.News.RssFetcherStub do
  def fetch(data_source) do
    case Process.get({__MODULE__, data_source.slug}) do
      nil -> {:ok, default_articles(data_source)}
      response -> response
    end
  end

  def put_response(slug, response) do
    Process.put({__MODULE__, slug}, response)
  end

  defp default_articles(data_source) do
    [
      %{
        data_source_id: data_source.id,
        guid: "guid-#{data_source.slug}",
        title: "Headline for #{data_source.name}",
        description: "Story from #{data_source.name}",
        url: "#{data_source.base_url}/articles/#{data_source.slug}",
        image_url: nil,
        author: nil,
        categories: ["World"],
        published_at: ~U[2026-03-24 12:00:00Z]
      }
    ]
  end
end
