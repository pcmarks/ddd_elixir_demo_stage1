use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Where to find the resource files used during development. The files are
# copied here *only* if the directory is empty.
app_dir = File.cwd!()
config :shipping,
  dev_resources_cache: Path.join([app_dir, "resources", "dev"])
