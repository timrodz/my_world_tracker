defmodule WorldTracker.Seeds do
  import Ecto.Query

  alias WorldTracker.Repo

  @data_sources [
    %{
      name: "Yahoo Finance",
      slug: "yahoo_finance",
      base_url: "https://finance.yahoo.com",
      type: "markets"
    },
    %{
      name: "BBC News",
      slug: "bbc_news",
      base_url: "https://feeds.bbci.co.uk",
      type: "news",
      endpoint_url: "https://feeds.bbci.co.uk/news/world/rss.xml"
    },
    %{
      name: "Al Jazeera",
      slug: "al_jazeera",
      base_url: "https://www.aljazeera.com",
      type: "news",
      endpoint_url: "https://www.aljazeera.com/xml/rss/all.xml"
    },
    %{
      name: "The Guardian",
      slug: "the_guardian",
      base_url: "https://www.theguardian.com",
      type: "news",
      endpoint_url: "https://www.theguardian.com/world/rss"
    },
    %{
      name: "NPR World",
      slug: "npr_world",
      base_url: "https://feeds.npr.org",
      type: "news",
      endpoint_url: "https://feeds.npr.org/1004/rss.xml"
    },
    %{
      name: "AISStream",
      slug: "aisstream",
      base_url: "wss://stream.aisstream.io",
      type: "locations",
      endpoint_url: "/v0/stream"
    }
  ]

  @market_tickers [
    %{symbol: "GC=F", name: "Gold"},
    %{symbol: "SI=F", name: "Silver"},
    %{symbol: "CL=F", name: "Crude Oil"},
    %{symbol: "DX-Y.NYB", name: "US Dollar Index"},
    %{symbol: "EURUSD=X", name: "EUR / USD"},
    %{symbol: "GBPUSD=X", name: "GBP / USD"},
    %{symbol: "^GSPC", name: "S&P 500"},
    %{symbol: "^DJI", name: "Dow Jones"},
    %{symbol: "^RUT", name: "Russell 2000"},
    %{symbol: "^N225", name: "Nikkei 225"},
    %{symbol: "BZ=F", name: "Brent Crude Oil"},
    %{symbol: "NG=F", name: "Natural Gas"},
    %{symbol: "HO=F", name: "Heating Oil"},
    %{symbol: "RB=F", name: "RBOB Gasoline"}
  ]

  # TODO: Might remove this once I can get this data with an API
  @data_centers [
    %{
      name: "AWS US East (N. Virginia)",
      operator: "Amazon Web Services",
      city: "Ashburn",
      country_code: "US",
      latitude: 38.894,
      longitude: -77.448
    },
    %{
      name: "AWS US West (Oregon)",
      operator: "Amazon Web Services",
      city: "Hillsboro",
      country_code: "US",
      latitude: 45.522,
      longitude: -122.989
    },
    %{
      name: "AWS EU West (Ireland)",
      operator: "Amazon Web Services",
      city: "Dublin",
      country_code: "IE",
      latitude: 53.345,
      longitude: -6.259
    },
    %{
      name: "AWS EU Central (Frankfurt)",
      operator: "Amazon Web Services",
      city: "Frankfurt",
      country_code: "DE",
      latitude: 50.109,
      longitude: 8.677
    },
    %{
      name: "AWS EU West 2 (London)",
      operator: "Amazon Web Services",
      city: "London",
      country_code: "GB",
      latitude: 51.507,
      longitude: -0.127
    },
    %{
      name: "AWS AP Northeast (Tokyo)",
      operator: "Amazon Web Services",
      city: "Tokyo",
      country_code: "JP",
      latitude: 35.652,
      longitude: 139.839
    },
    %{
      name: "AWS AP Southeast (Singapore)",
      operator: "Amazon Web Services",
      city: "Singapore",
      country_code: "SG",
      latitude: 1.35,
      longitude: 103.82
    },
    %{
      name: "AWS AP Southeast 2 (Sydney)",
      operator: "Amazon Web Services",
      city: "Sydney",
      country_code: "AU",
      latitude: -33.869,
      longitude: 151.209
    },
    %{
      name: "AWS AP South (Mumbai)",
      operator: "Amazon Web Services",
      city: "Mumbai",
      country_code: "IN",
      latitude: 19.076,
      longitude: 72.877
    },
    %{
      name: "AWS SA East (São Paulo)",
      operator: "Amazon Web Services",
      city: "São Paulo",
      country_code: "BR",
      latitude: -23.549,
      longitude: -46.633
    },
    %{
      name: "AWS CA Central (Montreal)",
      operator: "Amazon Web Services",
      city: "Montreal",
      country_code: "CA",
      latitude: 45.501,
      longitude: -73.567
    },
    %{
      name: "AWS ME South (Bahrain)",
      operator: "Amazon Web Services",
      city: "Manama",
      country_code: "BH",
      latitude: 26.066,
      longitude: 50.558
    },
    %{
      name: "AWS AF South (Cape Town)",
      operator: "Amazon Web Services",
      city: "Cape Town",
      country_code: "ZA",
      latitude: -33.925,
      longitude: 18.424
    },
    %{
      name: "GCP US Central (Iowa)",
      operator: "Google Cloud",
      city: "Council Bluffs",
      country_code: "US",
      latitude: 41.262,
      longitude: -95.861
    },
    %{
      name: "GCP US East (South Carolina)",
      operator: "Google Cloud",
      city: "Moncks Corner",
      country_code: "US",
      latitude: 33.196,
      longitude: -80.012
    },
    %{
      name: "GCP EU West (Belgium)",
      operator: "Google Cloud",
      city: "St. Ghislain",
      country_code: "BE",
      latitude: 50.454,
      longitude: 3.778
    },
    %{
      name: "GCP EU North (Finland)",
      operator: "Google Cloud",
      city: "Hamina",
      country_code: "FI",
      latitude: 60.567,
      longitude: 27.197
    },
    %{
      name: "GCP Asia East (Taiwan)",
      operator: "Google Cloud",
      city: "Changhua County",
      country_code: "TW",
      latitude: 24.063,
      longitude: 120.516
    },
    %{
      name: "GCP Asia Southeast (Singapore)",
      operator: "Google Cloud",
      city: "Singapore",
      country_code: "SG",
      latitude: 1.352,
      longitude: 103.822
    },
    %{
      name: "GCP Asia South (Mumbai)",
      operator: "Google Cloud",
      city: "Mumbai",
      country_code: "IN",
      latitude: 19.079,
      longitude: 72.88
    },
    %{
      name: "Azure East US (Virginia)",
      operator: "Microsoft Azure",
      city: "Boydton",
      country_code: "US",
      latitude: 36.669,
      longitude: -78.388
    },
    %{
      name: "Azure West US (California)",
      operator: "Microsoft Azure",
      city: "San Jose",
      country_code: "US",
      latitude: 37.338,
      longitude: -121.886
    },
    %{
      name: "Azure North Europe (Ireland)",
      operator: "Microsoft Azure",
      city: "Dublin",
      country_code: "IE",
      latitude: 53.347,
      longitude: -6.261
    },
    %{
      name: "Azure West Europe (Netherlands)",
      operator: "Microsoft Azure",
      city: "Amsterdam",
      country_code: "NL",
      latitude: 52.377,
      longitude: 4.897
    },
    %{
      name: "Azure Southeast Asia (Singapore)",
      operator: "Microsoft Azure",
      city: "Singapore",
      country_code: "SG",
      latitude: 1.353,
      longitude: 103.819
    },
    %{
      name: "Azure Japan East (Tokyo)",
      operator: "Microsoft Azure",
      city: "Tokyo",
      country_code: "JP",
      latitude: 35.654,
      longitude: 139.841
    },
    %{
      name: "Azure Brazil South (São Paulo)",
      operator: "Microsoft Azure",
      city: "São Paulo",
      country_code: "BR",
      latitude: -23.551,
      longitude: -46.635
    },
    %{
      name: "Azure Australia East (Sydney)",
      operator: "Microsoft Azure",
      city: "Sydney",
      country_code: "AU",
      latitude: -33.871,
      longitude: 151.207
    },
    %{
      name: "Azure UAE North (Dubai)",
      operator: "Microsoft Azure",
      city: "Dubai",
      country_code: "AE",
      latitude: 25.204,
      longitude: 55.27
    },
    %{
      name: "Equinix LD5 (London)",
      operator: "Equinix",
      city: "London",
      country_code: "GB",
      latitude: 51.518,
      longitude: -0.081
    },
    %{
      name: "Equinix FR4 (Frankfurt)",
      operator: "Equinix",
      city: "Frankfurt",
      country_code: "DE",
      latitude: 50.116,
      longitude: 8.695
    },
    %{
      name: "Equinix AM3 (Amsterdam)",
      operator: "Equinix",
      city: "Amsterdam",
      country_code: "NL",
      latitude: 52.372,
      longitude: 4.898
    },
    %{
      name: "Equinix SG1 (Singapore)",
      operator: "Equinix",
      city: "Singapore",
      country_code: "SG",
      latitude: 1.354,
      longitude: 103.817
    },
    %{
      name: "Equinix TY2 (Tokyo)",
      operator: "Equinix",
      city: "Tokyo",
      country_code: "JP",
      latitude: 35.66,
      longitude: 139.845
    },
    %{
      name: "Equinix DC2 (Ashburn)",
      operator: "Equinix",
      city: "Ashburn",
      country_code: "US",
      latitude: 38.897,
      longitude: -77.446
    },
    %{
      name: "Equinix SY3 (Sydney)",
      operator: "Equinix",
      city: "Sydney",
      country_code: "AU",
      latitude: -33.877,
      longitude: 151.201
    }
  ]

  # TODO: Might remove this once I can get this data with an API
  @oil_facilities [
    %{
      name: "Ghawar Oil Field",
      subtype: "oil_field",
      operator: "Aramco",
      country_code: "SA",
      latitude: 24.889,
      longitude: 49.175
    },
    %{
      name: "Rumaila Oil Field",
      subtype: "oil_field",
      operator: "Basra Oil Company",
      country_code: "IQ",
      latitude: 30.022,
      longitude: 47.525
    },
    %{
      name: "Burgan Oil Field",
      subtype: "oil_field",
      operator: "Kuwait Oil Company",
      country_code: "KW",
      latitude: 29.022,
      longitude: 47.943
    },
    %{
      name: "Ahvaz Oil Field",
      subtype: "oil_field",
      operator: "NIOC",
      country_code: "IR",
      latitude: 31.438,
      longitude: 49.688
    },
    %{
      name: "Permian Basin",
      subtype: "oil_field",
      operator: "Multiple",
      country_code: "US",
      latitude: 31.831,
      longitude: -102.118
    },
    %{
      name: "Prudhoe Bay Oil Field",
      subtype: "oil_field",
      operator: "BP / ConocoPhillips",
      country_code: "US",
      latitude: 70.255,
      longitude: -148.337
    },
    %{
      name: "Johan Sverdrup Field",
      subtype: "oil_field",
      operator: "Equinor",
      country_code: "NO",
      latitude: 58.844,
      longitude: 2.663
    },
    %{
      name: "Cantarell Complex",
      subtype: "oil_field",
      operator: "Pemex",
      country_code: "MX",
      latitude: 19.716,
      longitude: -91.884
    },
    %{
      name: "Orinoco Belt",
      subtype: "oil_field",
      operator: "PDVSA",
      country_code: "VE",
      latitude: 8.195,
      longitude: -63.766
    },
    %{
      name: "Kashagan Oil Field",
      subtype: "oil_field",
      operator: "NCOC",
      country_code: "KZ",
      latitude: 45.468,
      longitude: 53.052
    },
    %{
      name: "Tengiz Oil Field",
      subtype: "oil_field",
      operator: "TengizChevroil",
      country_code: "KZ",
      latitude: 45.466,
      longitude: 53.148
    },
    %{
      name: "Buzios Pre-Salt Field",
      subtype: "oil_field",
      operator: "Petrobras",
      country_code: "BR",
      latitude: -22.884,
      longitude: -40.886
    },
    %{
      name: "Port Arthur Refinery",
      subtype: "refinery",
      operator: "Motiva Enterprises",
      country_code: "US",
      latitude: 29.885,
      longitude: -93.93
    },
    %{
      name: "Ruwais Refinery",
      subtype: "refinery",
      operator: "ADNOC",
      country_code: "AE",
      latitude: 24.113,
      longitude: 52.737
    },
    %{
      name: "Jamnagar Refinery",
      subtype: "refinery",
      operator: "Reliance Industries",
      country_code: "IN",
      latitude: 22.467,
      longitude: 70.074
    },
    %{
      name: "Rotterdam Refinery Complex",
      subtype: "refinery",
      operator: "Shell / BP",
      country_code: "NL",
      latitude: 51.908,
      longitude: 4.27
    },
    %{
      name: "Ulsan Refinery",
      subtype: "refinery",
      operator: "SK Innovation",
      country_code: "KR",
      latitude: 35.534,
      longitude: 129.319
    },
    %{
      name: "Ras Tanura Refinery",
      subtype: "refinery",
      operator: "Aramco",
      country_code: "SA",
      latitude: 26.626,
      longitude: 50.158
    },
    %{
      name: "Jurong Island Refinery",
      subtype: "refinery",
      operator: "ExxonMobil",
      country_code: "SG",
      latitude: 1.266,
      longitude: 103.702
    },
    %{
      name: "Bandar Abbas Refinery",
      subtype: "refinery",
      operator: "NIOC",
      country_code: "IR",
      latitude: 27.183,
      longitude: 56.27
    },
    %{
      name: "Ras Laffan LNG Terminal",
      subtype: "lng_terminal",
      operator: "QatarEnergy",
      country_code: "QA",
      latitude: 25.976,
      longitude: 51.579
    },
    %{
      name: "Bonny LNG Terminal",
      subtype: "lng_terminal",
      operator: "NLNG",
      country_code: "NG",
      latitude: 4.441,
      longitude: 7.156
    },
    %{
      name: "Darwin LNG Terminal",
      subtype: "lng_terminal",
      operator: "Santos",
      country_code: "AU",
      latitude: -12.461,
      longitude: 130.819
    },
    %{
      name: "Sabine Pass LNG Terminal",
      subtype: "lng_terminal",
      operator: "Cheniere Energy",
      country_code: "US",
      latitude: 29.725,
      longitude: -93.89
    },
    %{
      name: "Ichthys LNG Terminal",
      subtype: "lng_terminal",
      operator: "INPEX",
      country_code: "AU",
      latitude: -12.462,
      longitude: 130.82
    },
    %{
      name: "Hibernia Platform",
      subtype: "offshore_platform",
      operator: "ExxonMobil",
      country_code: "CA",
      latitude: 46.749,
      longitude: -48.774
    },
    %{
      name: "Bonga FPSO",
      subtype: "offshore_platform",
      operator: "Shell Nigeria",
      country_code: "NG",
      latitude: 3.527,
      longitude: 4.851
    },
    %{
      name: "Johan Castberg FPSO",
      subtype: "offshore_platform",
      operator: "Equinor",
      country_code: "NO",
      latitude: 72.0,
      longitude: 21.0
    }
  ]

  def run do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    seed_data_sources(now)
    seed_tickers(now)
    seed_countries(now)
    seed_locations(now)
  end

  defp seed_data_sources(now) do
    rows =
      Enum.map(@data_sources, fn data_source ->
        Map.merge(data_source, %{inserted_at: now, updated_at: now})
      end)

    Repo.insert_all("data_sources", rows,
      on_conflict: :nothing,
      conflict_target: [:slug]
    )
  end

  defp seed_tickers(now) do
    yahoo_finance_id =
      Repo.one(
        from(ds in "data_sources",
          where: ds.slug == "yahoo_finance",
          select: ds.id
        )
      )

    unless is_nil(yahoo_finance_id) do
      rows =
        Enum.map(@market_tickers, fn ticker ->
          %{
            data_source_id: yahoo_finance_id,
            symbol: ticker.symbol,
            name: ticker.name,
            inserted_at: now,
            updated_at: now
          }
        end)

      Repo.insert_all("tickers", rows,
        on_conflict: :nothing,
        conflict_target: [:data_source_id, :symbol]
      )
    end
  end

  defp seed_countries(now) do
    rows =
      Enum.map(raw_countries(), fn {alpha2, name} ->
        %{alpha2_code: alpha2, name: name, inserted_at: now, updated_at: now}
      end)

    Repo.insert_all("countries", rows, on_conflict: :nothing, conflict_target: [:alpha2_code])
  end

  defp seed_locations(now) do
    alpha2_to_country_id =
      Repo.all(from(c in "countries", select: {c.alpha2_code, c.id}))
      |> Map.new()

    seed_data_centers(alpha2_to_country_id, now)
    seed_oil_facilities(alpha2_to_country_id, now)
  end

  defp seed_data_centers(alpha2_to_country_id, now) do
    existing_names =
      Repo.all(
        from(l in "locations",
          where: l.type == "data_center",
          select: l.name
        )
      )
      |> MapSet.new()

    rows =
      @data_centers
      |> Enum.reject(&MapSet.member?(existing_names, &1.name))
      |> Enum.map(fn data_center ->
        %{
          name: data_center.name,
          type: "data_center",
          operator: data_center.operator,
          city: data_center.city,
          latitude: data_center.latitude,
          longitude: data_center.longitude,
          country_id: Map.get(alpha2_to_country_id, data_center.country_code),
          inserted_at: now,
          updated_at: now
        }
      end)

    if rows != [] do
      Repo.insert_all("locations", rows)
    end
  end

  defp seed_oil_facilities(alpha2_to_country_id, now) do
    existing_names =
      Repo.all(
        from(l in "locations",
          where: l.type == "oil_facility",
          select: l.name
        )
      )
      |> MapSet.new()

    rows =
      @oil_facilities
      |> Enum.reject(&MapSet.member?(existing_names, &1.name))
      |> Enum.map(fn facility ->
        %{
          name: facility.name,
          type: "oil_facility",
          subtype: facility.subtype,
          operator: facility.operator,
          latitude: facility.latitude,
          longitude: facility.longitude,
          country_id: Map.get(alpha2_to_country_id, facility.country_code),
          inserted_at: now,
          updated_at: now
        }
      end)

    if rows != [] do
      Repo.insert_all("locations", rows)
    end
  end

  defp raw_countries do
    [
      {"AF", "Afghanistan"},
      {"AX", "Aland Islands"},
      {"AL", "Albania"},
      {"DZ", "Algeria"},
      {"AS", "American Samoa"},
      {"AD", "Andorra"},
      {"AO", "Angola"},
      {"AI", "Anguilla"},
      {"AQ", "Antarctica"},
      {"AG", "Antigua And Barbuda"},
      {"AR", "Argentina"},
      {"AM", "Armenia"},
      {"AW", "Aruba"},
      {"AU", "Australia"},
      {"AT", "Austria"},
      {"AZ", "Azerbaijan"},
      {"BS", "Bahamas"},
      {"BH", "Bahrain"},
      {"BD", "Bangladesh"},
      {"BB", "Barbados"},
      {"BY", "Belarus"},
      {"BE", "Belgium"},
      {"BZ", "Belize"},
      {"BJ", "Benin"},
      {"BM", "Bermuda"},
      {"BT", "Bhutan"},
      {"BO", "Bolivia"},
      {"BA", "Bosnia And Herzegovina"},
      {"BW", "Botswana"},
      {"BV", "Bouvet Island"},
      {"BR", "Brazil"},
      {"IO", "British Indian Ocean Territory"},
      {"BN", "Brunei Darussalam"},
      {"BG", "Bulgaria"},
      {"BF", "Burkina Faso"},
      {"BI", "Burundi"},
      {"KH", "Cambodia"},
      {"CM", "Cameroon"},
      {"CA", "Canada"},
      {"CV", "Cape Verde"},
      {"KY", "Cayman Islands"},
      {"CF", "Central African Republic"},
      {"TD", "Chad"},
      {"CL", "Chile"},
      {"CN", "China"},
      {"CX", "Christmas Island"},
      {"CC", "Cocos (Keeling) Islands"},
      {"CO", "Colombia"},
      {"KM", "Comoros"},
      {"CG", "Congo"},
      {"CD", "Congo, Democratic Republic"},
      {"CK", "Cook Islands"},
      {"CR", "Costa Rica"},
      {"CI", "Cote D\"Ivoire"},
      {"HR", "Croatia"},
      {"CU", "Cuba"},
      {"CY", "Cyprus"},
      {"CZ", "Czech Republic"},
      {"DK", "Denmark"},
      {"DJ", "Djibouti"},
      {"DM", "Dominica"},
      {"DO", "Dominican Republic"},
      {"EC", "Ecuador"},
      {"EG", "Egypt"},
      {"SV", "El Salvador"},
      {"GQ", "Equatorial Guinea"},
      {"ER", "Eritrea"},
      {"EE", "Estonia"},
      {"ET", "Ethiopia"},
      {"FK", "Falkland Islands (Malvinas)"},
      {"FO", "Faroe Islands"},
      {"FJ", "Fiji"},
      {"FI", "Finland"},
      {"FR", "France"},
      {"GF", "French Guiana"},
      {"PF", "French Polynesia"},
      {"TF", "French Southern Territories"},
      {"GA", "Gabon"},
      {"GM", "Gambia"},
      {"GE", "Georgia"},
      {"DE", "Germany"},
      {"GH", "Ghana"},
      {"GI", "Gibraltar"},
      {"GR", "Greece"},
      {"GL", "Greenland"},
      {"GD", "Grenada"},
      {"GP", "Guadeloupe"},
      {"GU", "Guam"},
      {"GT", "Guatemala"},
      {"GG", "Guernsey"},
      {"GN", "Guinea"},
      {"GW", "Guinea-Bissau"},
      {"GY", "Guyana"},
      {"HT", "Haiti"},
      {"HM", "Heard Island & Mcdonald Islands"},
      {"VA", "Holy See (Vatican City State)"},
      {"HN", "Honduras"},
      {"HK", "Hong Kong"},
      {"HU", "Hungary"},
      {"IS", "Iceland"},
      {"IN", "India"},
      {"ID", "Indonesia"},
      {"IR", "Iran, Islamic Republic Of"},
      {"IQ", "Iraq"},
      {"IE", "Ireland"},
      {"IM", "Isle Of Man"},
      {"IL", "Israel"},
      {"IT", "Italy"},
      {"JM", "Jamaica"},
      {"JP", "Japan"},
      {"JE", "Jersey"},
      {"JO", "Jordan"},
      {"KZ", "Kazakhstan"},
      {"KE", "Kenya"},
      {"KI", "Kiribati"},
      {"KR", "Korea"},
      {"KP", "North Korea"},
      {"KW", "Kuwait"},
      {"KG", "Kyrgyzstan"},
      {"LA", "Lao People\"s Democratic Republic"},
      {"LV", "Latvia"},
      {"LB", "Lebanon"},
      {"LS", "Lesotho"},
      {"LR", "Liberia"},
      {"LY", "Libyan Arab Jamahiriya"},
      {"LI", "Liechtenstein"},
      {"LT", "Lithuania"},
      {"LU", "Luxembourg"},
      {"MO", "Macao"},
      {"MK", "Macedonia"},
      {"MG", "Madagascar"},
      {"MW", "Malawi"},
      {"MY", "Malaysia"},
      {"MV", "Maldives"},
      {"ML", "Mali"},
      {"MT", "Malta"},
      {"MH", "Marshall Islands"},
      {"MQ", "Martinique"},
      {"MR", "Mauritania"},
      {"MU", "Mauritius"},
      {"YT", "Mayotte"},
      {"MX", "Mexico"},
      {"FM", "Micronesia, Federated States Of"},
      {"MD", "Moldova"},
      {"MC", "Monaco"},
      {"MN", "Mongolia"},
      {"ME", "Montenegro"},
      {"MS", "Montserrat"},
      {"MA", "Morocco"},
      {"MZ", "Mozambique"},
      {"MM", "Myanmar"},
      {"NA", "Namibia"},
      {"NR", "Nauru"},
      {"NP", "Nepal"},
      {"NL", "Netherlands"},
      {"AN", "Netherlands Antilles"},
      {"NC", "New Caledonia"},
      {"NZ", "New Zealand"},
      {"NI", "Nicaragua"},
      {"NE", "Niger"},
      {"NG", "Nigeria"},
      {"NU", "Niue"},
      {"NF", "Norfolk Island"},
      {"MP", "Northern Mariana Islands"},
      {"NO", "Norway"},
      {"OM", "Oman"},
      {"PK", "Pakistan"},
      {"PW", "Palau"},
      {"PS", "Palestinian Territory, Occupied"},
      {"PA", "Panama"},
      {"PG", "Papua New Guinea"},
      {"PY", "Paraguay"},
      {"PE", "Peru"},
      {"PH", "Philippines"},
      {"PN", "Pitcairn"},
      {"PL", "Poland"},
      {"PT", "Portugal"},
      {"PR", "Puerto Rico"},
      {"QA", "Qatar"},
      {"RE", "Reunion"},
      {"RO", "Romania"},
      {"RU", "Russian Federation"},
      {"RW", "Rwanda"},
      {"BL", "Saint Barthelemy"},
      {"SH", "Saint Helena"},
      {"KN", "Saint Kitts And Nevis"},
      {"LC", "Saint Lucia"},
      {"MF", "Saint Martin"},
      {"PM", "Saint Pierre And Miquelon"},
      {"VC", "Saint Vincent And Grenadines"},
      {"WS", "Samoa"},
      {"SM", "San Marino"},
      {"ST", "Sao Tome And Principe"},
      {"SA", "Saudi Arabia"},
      {"SN", "Senegal"},
      {"RS", "Serbia"},
      {"SC", "Seychelles"},
      {"SL", "Sierra Leone"},
      {"SG", "Singapore"},
      {"SK", "Slovakia"},
      {"SI", "Slovenia"},
      {"SB", "Solomon Islands"},
      {"SO", "Somalia"},
      {"ZA", "South Africa"},
      {"GS", "South Georgia And Sandwich Isl."},
      {"ES", "Spain"},
      {"LK", "Sri Lanka"},
      {"SD", "Sudan"},
      {"SR", "Suriname"},
      {"SJ", "Svalbard And Jan Mayen"},
      {"SZ", "Swaziland"},
      {"SE", "Sweden"},
      {"CH", "Switzerland"},
      {"SY", "Syrian Arab Republic"},
      {"TW", "Taiwan"},
      {"TJ", "Tajikistan"},
      {"TZ", "Tanzania"},
      {"TH", "Thailand"},
      {"TL", "Timor-Leste"},
      {"TG", "Togo"},
      {"TK", "Tokelau"},
      {"TO", "Tonga"},
      {"TT", "Trinidad And Tobago"},
      {"TN", "Tunisia"},
      {"TR", "Turkey"},
      {"TM", "Turkmenistan"},
      {"TC", "Turks And Caicos Islands"},
      {"TV", "Tuvalu"},
      {"UG", "Uganda"},
      {"UA", "Ukraine"},
      {"AE", "United Arab Emirates"},
      {"GB", "United Kingdom"},
      {"US", "United States"},
      {"UM", "United States Outlying Islands"},
      {"UY", "Uruguay"},
      {"UZ", "Uzbekistan"},
      {"VU", "Vanuatu"},
      {"VE", "Venezuela"},
      {"VN", "Vietnam"},
      {"VG", "Virgin Islands, British"},
      {"VI", "Virgin Islands, U.S."},
      {"WF", "Wallis And Futuna"},
      {"EH", "Western Sahara"},
      {"YE", "Yemen"},
      {"ZM", "Zambia"},
      {"ZW", "Zimbabwe"}
    ]
  end
end

WorldTracker.Seeds.run()
