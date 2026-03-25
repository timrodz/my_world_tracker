# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :world_tracker, Oban,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"*/5 * * * *", WorldTracker.Markets.PricePoller},
       {"*/30 * * * *", WorldTracker.News.FetchNewsWorker}
     ]}
  ],
  queues: [default: 10, market_prices: 1, news: 4],
  repo: WorldTracker.Repo

config :world_tracker,
  ecto_repos: [WorldTracker.Repo],
  generators: [timestamp_type: :utc_datetime],
  market_quote_fetchers: %{"yahoo_finance" => WorldTracker.Markets.YahooFinance}

config :pythonx, :uv_init,
  pyproject_toml: """
  [project]
  name = "world_tracker"
  version = "0.1.0"
  requires-python = "==3.12.*"
  dependencies = ["yfinance>=1.2.0"]
  """

# Configures the endpoint
config :world_tracker, WorldTrackerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WorldTrackerWeb.ErrorHTML, json: WorldTrackerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WorldTracker.PubSub,
  live_view: [signing_salt: "tqR/Pp+c"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :world_tracker, WorldTracker.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  world_tracker: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../assets/node_modules", __DIR__), Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  world_tracker: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
