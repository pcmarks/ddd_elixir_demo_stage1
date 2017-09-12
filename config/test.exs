use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Where to find the resource files used during testing. The files are
# copied here during test set up and overwrite any that are present.
app_dir = File.cwd!()
config :shipping,
  test_resources_cache: Path.join([app_dir, "resources", "test"])
