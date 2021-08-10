# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :appsignal_phoenix_example,
  ecto_repos: [AppsignalPhoenixExample.Repo]

# Configures the endpoint
config :appsignal_phoenix_example, AppsignalPhoenixExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PZ4RULxrjU4UUxV3tOQb/j8SkP5JaOCzikd73bVx9yrfajwhCvIsSuKgodEKTFhF",
  render_errors: [view: AppsignalPhoenixExampleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AppsignalPhoenixExample.PubSub,
  live_view: [signing_salt: "IgA+PR6P"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :appsignal, :config,
  otp_app: :appsignal_phoenix_example

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
