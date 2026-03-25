defmodule WorldTracker.Shipping.AisStreamClient do
  @moduledoc """
  WebSocket client for the AISStream.io real-time AIS feed.

  Connects to `wss://stream.aisstream.io/v0/stream`, subscribes globally,
  and upserts vessel position and static data into the `ships` table,
  broadcasting updates over PubSub.

  The process is supervised and reconnects automatically on disconnect.
  It will not start if no API key is configured.
  """

  use WebSockex

  require Logger

  alias Phoenix.PubSub
  alias WorldTracker.Shipping

  @url "wss://stream.aisstream.io/v0/stream"

  # Well-known supertankers (VLCC / oil tankers) from major global routes.
  # TI Class: 444,000 dwt supertankers — among the largest active ships.
  # Verify or update MMSIs at https://www.vesselfinder.com/
  # @ships_to_track %{
  #   # TI Class supertankers (Panama)
  #   355_593_000 => "TI ASIA",
  #   355_136_000 => "TI AFRICA",
  #   355_305_000 => "TI EUROPE",
  #   353_282_000 => "TI OCEANIA",
  #   # Large tankers
  #   373_972_000 => "POLAR ENDEAVOUR",
  #   353_858_000 => "OVERSEAS GEORGIA",
  #   314_814_000 => "SEAWAYS AMERICA",
  #   356_235_000 => "DELTA OCEAN",
  #   636_093_000 => "PACIFIC GEM",
  #   538_009_000 => "MILLENIA"
  # }

  @mid_to_country %{
    201 => "AL",
    202 => "AD",
    203 => "AT",
    204 => "PT",
    205 => "BE",
    206 => "BY",
    207 => "BG",
    208 => "VA",
    209 => "CY",
    210 => "CY",
    211 => "DE",
    212 => "CY",
    213 => "GE",
    214 => "MD",
    215 => "MT",
    216 => "AM",
    218 => "DE",
    219 => "DK",
    220 => "DK",
    224 => "ES",
    225 => "ES",
    226 => "FR",
    227 => "FR",
    228 => "FR",
    229 => "MT",
    230 => "FI",
    231 => "FO",
    232 => "GB",
    233 => "GB",
    234 => "GB",
    235 => "GB",
    236 => "GI",
    237 => "GR",
    238 => "HR",
    239 => "GR",
    240 => "GR",
    241 => "GR",
    242 => "MA",
    243 => "HU",
    244 => "NL",
    245 => "NL",
    246 => "NL",
    247 => "IT",
    248 => "MT",
    249 => "MT",
    250 => "IE",
    251 => "IS",
    252 => "LI",
    253 => "LU",
    254 => "MC",
    255 => "PT",
    256 => "MT",
    257 => "NO",
    258 => "NO",
    259 => "NO",
    261 => "PL",
    262 => "ME",
    263 => "PT",
    264 => "RO",
    265 => "SE",
    266 => "SE",
    267 => "SK",
    268 => "SM",
    269 => "CH",
    270 => "CZ",
    271 => "TR",
    272 => "UA",
    273 => "RU",
    274 => "MK",
    275 => "LV",
    276 => "EE",
    277 => "LT",
    278 => "SI",
    279 => "RS",
    301 => "AG",
    303 => "US",
    304 => "AG",
    305 => "AG",
    306 => "NL",
    307 => "AW",
    308 => "BS",
    309 => "BS",
    310 => "BM",
    311 => "BS",
    312 => "BZ",
    314 => "BB",
    316 => "CA",
    319 => "KY",
    321 => "CR",
    323 => "CU",
    325 => "DM",
    327 => "DO",
    329 => "GP",
    330 => "GD",
    331 => "GL",
    332 => "GT",
    334 => "HN",
    336 => "HT",
    338 => "US",
    339 => "JM",
    341 => "KN",
    343 => "LC",
    345 => "MX",
    347 => "MQ",
    348 => "MS",
    350 => "NI",
    351 => "PA",
    352 => "PA",
    353 => "PA",
    354 => "PA",
    355 => "PA",
    356 => "PA",
    357 => "PA",
    358 => "PR",
    359 => "SV",
    361 => "PM",
    362 => "TT",
    364 => "TC",
    366 => "US",
    367 => "US",
    368 => "US",
    369 => "US",
    370 => "PA",
    371 => "PA",
    372 => "PA",
    373 => "PA",
    374 => "PA",
    375 => "VC",
    376 => "VC",
    377 => "VC",
    378 => "VG",
    379 => "VI",
    401 => "AF",
    403 => "SA",
    405 => "BD",
    408 => "BH",
    410 => "BT",
    412 => "CN",
    413 => "CN",
    414 => "CN",
    416 => "TW",
    422 => "IR",
    423 => "AZ",
    425 => "IQ",
    428 => "IL",
    431 => "JP",
    432 => "JP",
    434 => "TM",
    436 => "KZ",
    437 => "UZ",
    438 => "JO",
    440 => "KR",
    441 => "KR",
    443 => "PS",
    445 => "KP",
    447 => "KW",
    450 => "LB",
    451 => "KY",
    453 => "MO",
    455 => "MV",
    457 => "MN",
    459 => "NP",
    461 => "OM",
    463 => "PK",
    466 => "QA",
    468 => "SY",
    470 => "AE",
    471 => "AE",
    472 => "TJ",
    473 => "YE",
    477 => "HK",
    478 => "BA",
    501 => "AQ",
    503 => "AU",
    506 => "MM",
    508 => "BN",
    510 => "FM",
    511 => "PW",
    512 => "NZ",
    514 => "KH",
    515 => "KH",
    516 => "CX",
    518 => "CK",
    520 => "FJ",
    523 => "CC",
    525 => "ID",
    529 => "KI",
    531 => "LA",
    533 => "MY",
    536 => "MP",
    538 => "MH",
    540 => "NC",
    542 => "NU",
    544 => "NR",
    546 => "PF",
    548 => "PH",
    553 => "PG",
    555 => "PN",
    557 => "SB",
    559 => "WS",
    561 => "SG",
    563 => "SG",
    564 => "SG",
    565 => "SG",
    566 => "SG",
    567 => "TH",
    570 => "TO",
    572 => "TV",
    574 => "VN",
    576 => "VU",
    578 => "WF",
    601 => "ZA",
    603 => "AO",
    605 => "DZ",
    607 => "SH",
    608 => "BI",
    609 => "BJ",
    610 => "BW",
    611 => "CF",
    612 => "CM",
    613 => "CG",
    616 => "CI",
    617 => "KM",
    618 => "AQ",
    619 => "CV",
    620 => "DJ",
    621 => "EG",
    622 => "ER",
    624 => "ET",
    625 => "SO",
    626 => "GA",
    627 => "GH",
    629 => "GM",
    630 => "GN",
    631 => "GQ",
    632 => "GW",
    633 => "KE",
    634 => "SS",
    635 => "LS",
    636 => "LR",
    637 => "LY",
    638 => "MU",
    642 => "MG",
    644 => "ML",
    645 => "MR",
    647 => "MW",
    649 => "MZ",
    650 => "MR",
    654 => "NE",
    655 => "NG",
    656 => "NA",
    657 => "SO",
    659 => "RW",
    660 => "SD",
    661 => "SN",
    662 => "SL",
    663 => "ST",
    664 => "SZ",
    665 => "TD",
    666 => "TG",
    667 => "TN",
    668 => "TZ",
    669 => "UG",
    670 => "TZ",
    671 => "ZM",
    672 => "ZW",
    674 => "SD",
    677 => "SC",
    678 => "ZW",
    679 => "ZM"
  }

  def start_link(opts \\ []) do
    api_key = Keyword.get(opts, :api_key) || api_key_from_config()

    unless is_binary(api_key) and byte_size(api_key) > 0 do
      Logger.warning("AisStreamClient: AISSTREAM_API_KEY not configured, client will not start")

      :ignore
    else
      Logger.info("AisStreamClient: initiating WebSocket connection to #{@url}")

      subscription =
        Jason.encode!(%{
          "APIKey" => api_key,
          "BoundingBoxes" => [[[-90, -180], [90, 180]]]
        })

      WebSockex.start_link(
        @url,
        __MODULE__,
        %{data_source_id: nil, subscription: subscription},
        name: __MODULE__,
        handle_initial_conn_failure: true
      )
    end
  end

  @impl WebSockex
  def handle_connect(_conn, state) do
    Logger.info("AisStreamClient: connected to #{@url}")

    data_source_id =
      case Shipping.get_aisstream_data_source() do
        nil ->
          Logger.warning("AisStreamClient: AISStream data source not found in database")
          nil

        ds ->
          ds.id
      end

    # Trigger the subscription message after connect via handle_info.
    send(self(), :subscribe)

    {:ok, %{state | data_source_id: data_source_id}}
  end

  @impl true
  def handle_info(:subscribe, %{subscription: subscription} = state) do
    {:reply, {:text, subscription}, state}
  end

  def handle_info(_msg, state), do: {:ok, state}

  @impl WebSockex
  def handle_frame({:binary, msg}, state) do
    case Jason.decode(msg) do
      {:ok, payload} ->
        handle_payload(payload, state)

      {:error, reason} ->
        Logger.warning(
          "AisStreamClient: failed to decode binary message reason=#{inspect(reason)}"
        )

        {:error, state}
    end
  end

  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, payload} ->
        handle_payload(payload, state)

      {:error, reason} ->
        Logger.warning("AisStreamClient: failed to decode text message reason=#{inspect(reason)}")
        {:error, state}
    end
  end

  def handle_frame(frame, state) do
    Logger.debug("AisStreamClient: received unhandled frame=#{inspect(frame)}")
    {:error, state}
  end

  @impl WebSockex
  def handle_disconnect(%{reason: reason}, state) do
    Logger.warning("AisStreamClient: disconnected reason=#{inspect(reason)}, reconnecting…")
    {:reconnect, state}
  end

  @impl WebSockex
  def terminate(reason, _state) do
    Logger.warning("AisStreamClient: terminating reason=#{inspect(reason)}")
    :ok
  end

  defp handle_payload(
         %{"MessageType" => "PositionReport", "Message" => message, "MetaData" => meta},
         state
       ) do
    report = Map.get(message, "PositionReport", %{})
    mmsi = Map.get(meta, "MMSI") || Map.get(report, "UserID")

    latitude = Map.get(meta, "latitude") || Map.get(report, "Latitude")
    longitude = Map.get(meta, "longitude") || Map.get(report, "Longitude")

    Logger.debug(
      "AisStreamClient: PositionReport mmsi=#{mmsi} lat=#{latitude} lon=#{longitude} IMO=#{inspect(Map.get(report, "ImoNumber"))} data_source_id=#{inspect(state.data_source_id)}"
    )

    attrs = %{
      mmsi: mmsi,
      name: normalize_name(Map.get(meta, "ShipName")),
      latitude: latitude,
      longitude: longitude,
      speed: float_or_nil(Map.get(report, "Sog")),
      course: float_or_nil(Map.get(report, "Cog")),
      last_seen_at: parse_time(Map.get(meta, "time_utc")),
      data_source_id: state.data_source_id
    }

    upsert_and_broadcast(attrs, state)
  end

  defp handle_payload(
         %{"MessageType" => "ShipStaticData", "Message" => message, "MetaData" => meta},
         state
       ) do
    report = Map.get(message, "ShipStaticData", %{})
    mmsi = Map.get(meta, "MMSI") || Map.get(report, "UserID")

    Logger.debug(
      "AisStreamClient: ShipStaticData mmsi=#{mmsi} name=#{inspect(Map.get(report, "Name") || Map.get(meta, "ShipName"))} IMO=#{inspect(Map.get(report, "ImoNumber"))} data_source_id=#{inspect(state.data_source_id)}"
    )

    attrs = %{
      mmsi: mmsi,
      name: normalize_name(Map.get(report, "Name") || Map.get(meta, "ShipName")),
      ship_type: Map.get(report, "Type"),
      flag: Map.get(report, "Flag") || country_code_from_mmsi(mmsi),
      destination: normalize_name(Map.get(report, "Destination")),
      last_seen_at: parse_time(Map.get(meta, "time_utc")),
      data_source_id: state.data_source_id
    }

    upsert_and_broadcast(attrs, state)
  end

  defp handle_payload(_payload, state) do
    {:ok, state}
  end

  defp upsert_and_broadcast(attrs, state) do
    if is_nil(attrs[:mmsi]) or is_nil(attrs[:data_source_id]) do
      Logger.debug(
        "AisStreamClient: skipping upsert, mmsi=#{inspect(attrs[:mmsi])} data_source_id=#{inspect(attrs[:data_source_id])}"
      )

      {:ok, state}
    else
      Logger.debug("AisStreamClient: upserting ship mmsi=#{attrs[:mmsi]}")

      case Shipping.upsert_ship(attrs) do
        {:ok, ship} ->
          Logger.debug(
            "AisStreamClient: upserted ship mmsi=#{ship.mmsi} id=#{ship.id}, broadcasting"
          )

          PubSub.broadcast(WorldTracker.PubSub, Shipping.topic(), {:ship_updated, ship})

        {:error, reason} ->
          Logger.warning(
            "AisStreamClient: failed to upsert ship mmsi=#{attrs[:mmsi]} reason=#{inspect(reason)}"
          )
      end

      {:ok, state}
    end
  end

  defp normalize_name(nil), do: nil

  defp normalize_name(name) when is_binary(name) do
    trimmed = String.trim(name)
    if trimmed == "", do: nil, else: trimmed
  end

  defp float_or_nil(nil), do: nil
  defp float_or_nil(v) when is_float(v), do: v
  defp float_or_nil(v) when is_integer(v), do: v / 1

  defp parse_time(nil), do: nil

  defp parse_time(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> DateTime.truncate(dt, :second)
      _ -> nil
    end
  end

  # Derive a rough country code from the MMSI MID (first 3 digits).
  # Best-effort fallback when ShipStaticData doesn't include a flag.
  defp country_code_from_mmsi(mmsi) when is_integer(mmsi) do
    mid = div(mmsi, 1_000_000)
    Map.get(@mid_to_country, mid)
  end

  defp country_code_from_mmsi(_), do: nil

  defp api_key_from_config do
    Application.get_env(:world_tracker, :aisstream_api_key)
  end
end
