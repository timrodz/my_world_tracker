defmodule WorldTracker.News.RssFetcher do
  @moduledoc """
  Fetches and parses RSS feeds for news data sources.

  Sources are queried from the database (`data_sources` where `type = :news`).
  Each source's `endpoint_url` is used for the HTTP request, and a per-slug
  normalizer maps the raw FastRSS item into an Article attribute map.
  """

  require Logger

  import Ecto.Query, warn: false

  alias WorldTracker.Repo
  alias WorldTracker.Sources.DataSource

  @month_map %{
    "Jan" => 1,
    "Feb" => 2,
    "Mar" => 3,
    "Apr" => 4,
    "May" => 5,
    "Jun" => 6,
    "Jul" => 7,
    "Aug" => 8,
    "Sep" => 9,
    "Oct" => 10,
    "Nov" => 11,
    "Dec" => 12
  }

  @doc """
  Returns all `DataSource` records with `type = :news`.
  """
  def list_news_sources do
    Repo.all(from(ds in DataSource, where: ds.type == :news, order_by: ds.name))
  end

  @doc """
  Fetches and parses the RSS feed for the given `%DataSource{}`.
  Returns `{:ok, [article_attrs]}` or `{:error, reason}`.
  """
  def fetch(%DataSource{slug: slug, endpoint_url: url, id: data_source_id})
      when is_binary(url) do
    Logger.debug("fetching rss source=#{slug} url=#{url}")

    case Req.get(url, receive_timeout: 15_000) do
      {:ok, %{status: 200, body: body}} ->
        parse(slug, body, data_source_id)

      {:ok, %{status: status}} ->
        {:error, "unexpected HTTP status #{status} for #{slug}"}

      {:error, reason} ->
        {:error, "HTTP request failed for #{slug}: #{inspect(reason)}"}
    end
  end

  def fetch(%DataSource{slug: slug, endpoint_url: nil}) do
    {:error, "no endpoint_url configured for source=#{slug}"}
  end

  defp parse(source_slug, body, data_source_id) do
    case FastRSS.parse_rss(body) do
      {:ok, feed} ->
        items = Map.get(feed, "items", [])
        attrs = Enum.map(items, &normalize(source_slug, &1, data_source_id))
        {:ok, attrs}

      {:error, reason} ->
        {:error, "RSS parse failed for #{source_slug}: #{inspect(reason)}"}
    end
  end

  # --- Per-source normalizers ---

  defp normalize("bbc_news", item, data_source_id) do
    %{
      data_source_id: data_source_id,
      guid: get_guid(item),
      title: get_string(item, "title"),
      description: get_string(item, "description"),
      url: get_link(item),
      image_url: get_media_thumbnail(item),
      author: nil,
      categories: get_categories(item),
      published_at: parse_pub_date(item)
    }
  end

  defp normalize("al_jazeera", item, data_source_id) do
    %{
      data_source_id: data_source_id,
      guid: get_guid(item),
      title: get_string(item, "title"),
      description: get_string(item, "description"),
      url: get_link(item),
      image_url: nil,
      author: nil,
      categories: get_categories(item),
      published_at: parse_pub_date(item)
    }
  end

  defp normalize("the_guardian", item, data_source_id) do
    %{
      data_source_id: data_source_id,
      guid: get_guid(item),
      title: get_string(item, "title"),
      description: get_string(item, "description"),
      url: get_link(item),
      image_url: get_media_content_url(item),
      author: get_dc_creator(item),
      categories: get_categories(item),
      published_at: parse_pub_date(item)
    }
  end

  defp normalize("npr_world", item, data_source_id) do
    %{
      data_source_id: data_source_id,
      guid: get_guid(item),
      title: get_string(item, "title"),
      description: get_string(item, "description"),
      url: get_link(item),
      image_url: get_media_thumbnail(item),
      author: get_dc_creator(item),
      categories: [],
      published_at: parse_pub_date(item)
    }
  end

  # Fallback normalizer for any unrecognised slug
  defp normalize(_slug, item, data_source_id) do
    %{
      data_source_id: data_source_id,
      guid: get_guid(item),
      title: get_string(item, "title"),
      description: get_string(item, "description"),
      url: get_link(item),
      image_url: get_media_thumbnail(item),
      author: get_dc_creator(item),
      categories: get_categories(item),
      published_at: parse_pub_date(item)
    }
  end

  # --- Field helpers ---

  defp get_string(item, key), do: item[key]

  defp get_guid(item) do
    case item["guid"] do
      %{"value" => val} when is_binary(val) and val != "" -> val
      _ -> item["link"] || item["title"]
    end
  end

  defp get_link(item), do: item["link"]

  defp get_categories(item) do
    case item["categories"] do
      cats when is_list(cats) ->
        cats
        |> Enum.map(fn
          %{"value" => v} when is_binary(v) -> String.trim(v)
          v when is_binary(v) -> String.trim(v)
          _ -> nil
        end)
        |> Enum.reject(&(is_nil(&1) or &1 == ""))

      _ ->
        []
    end
  end

  defp get_media_thumbnail(item) do
    case item["itunes"] do
      %{"image" => url} when is_binary(url) ->
        url

      _ ->
        case item["media_thumbnail"] do
          [%{"url" => url} | _] when is_binary(url) -> url
          _ -> nil
        end
    end
  end

  defp get_media_content_url(item) do
    case item["media_content"] do
      [%{"url" => url} | _] when is_binary(url) -> url
      _ -> get_media_thumbnail(item)
    end
  end

  defp get_dc_creator(item) do
    case item["dublin_core"] do
      %{"creator" => creator} when is_binary(creator) and creator != "" -> creator
      _ -> nil
    end
  end

  defp parse_pub_date(item) do
    case item["pub_date"] do
      date when is_binary(date) and date != "" -> parse_date_string(date)
      _ -> nil
    end
  end

  defp parse_date_string(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, dt, _} -> DateTime.truncate(dt, :second)
      _ -> parse_rfc2822(date_string)
    end
  end

  # Parses RFC 2822: "Mon, 24 Mar 2026 08:00:00 GMT" or "+0000"
  defp parse_rfc2822(date_string) do
    str = Regex.replace(~r/^\w+,\s*/, date_string, "")

    case String.split(String.trim(str), ~r/\s+/) do
      [day, month, year, time | _] ->
        with {d, ""} <- Integer.parse(day),
             {y, ""} <- Integer.parse(year),
             {:ok, month_num} <- Map.fetch(@month_map, month),
             [h_str, m_str, s_str] <- String.split(time, ":"),
             {h, ""} <- Integer.parse(h_str),
             {m, ""} <- Integer.parse(m_str),
             {s, ""} <- Integer.parse(s_str),
             {:ok, naive} <- NaiveDateTime.new(y, month_num, d, h, m, s),
             {:ok, dt} <- DateTime.from_naive(naive, "Etc/UTC") do
          dt
        else
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
