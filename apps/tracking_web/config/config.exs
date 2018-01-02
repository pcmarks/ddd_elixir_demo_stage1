# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tracking_web,
  namespace: TrackingWeb

# Configures the endpoint
config :tracking_web, TrackingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mtZVvYpu8LVpjIG4bmKyPLEw6d+Uvf5DqLhz2P9gmoWkHCmhszmBpz+PXquxnwc3",
  render_errors: [view: TrackingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TrackingWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :tracking_web, :generators,
  context_app: :shipping

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
