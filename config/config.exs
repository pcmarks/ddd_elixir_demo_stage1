# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure for Shipping's location of the Cargo and Handling
# Event agents resource files
app_dir = File.cwd!()
config :shipping,
  cargoes_cache: Path.join([app_dir, "resources", "cargoes.json"]),
  handling_events_cache: Path.join([app_dir, "resources", "handling_events.json"])

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
