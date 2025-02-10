# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir_phoenix_opentelemetry,
  ecto_repos: [ElixirPhoenixOpentelemetry.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :elixir_phoenix_opentelemetry, ElixirPhoenixOpentelemetryWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [
      html: ElixirPhoenixOpentelemetryWeb.ErrorHTML,
      json: ElixirPhoenixOpentelemetryWeb.ErrorJSON
    ],
    layout: false
  ],
  pubsub_server: ElixirPhoenixOpentelemetry.PubSub,
  live_view: [signing_salt: "WVEAHg8p"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :elixir_phoenix_opentelemetry, ElixirPhoenixOpentelemetry.Mailer,
  adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  elixir_phoenix_opentelemetry: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  elixir_phoenix_opentelemetry: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Add AppSignal and app configuration
{:ok, hostname} = :inet.gethostname()

config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :otlp,
  resource: [
    {"appsignal.config.name", System.get_env("APPSIGNAL_APP_NAME")},
    {"appsignal.config.environment", to_string(Mix.env())},
    {"appsignal.config.push_api_key", System.get_env("APPSIGNAL_PUSH_API_KEY")},
    {"appsignal.config.revision", "test-setups"},
    {"appsignal.config.language_integration", "elixir"},
    {"appsignal.config.app_path", File.cwd!()},
    {"service.name", "Phoenix"},
    {"host.name", hostname}
  ]

# Configure the OpenTelemetry HTTP exporter
config :opentelemetry_exporter,
  otlp_protocol: :http_protobuf,
  otlp_endpoint: "http://appsignal-collector:8099"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
