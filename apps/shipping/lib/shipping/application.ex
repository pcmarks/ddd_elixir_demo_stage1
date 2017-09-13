defmodule Shipping.Application do
  @moduledoc """
  The Shipping Application Service.

  The shipping system business domain lives in this application.

  Exposes API to clients such as the `Shipping.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      # Start up a supervised HandlingEventAgent and a CargoAgent to be used
      # in place of a database. Note that Repo is implemented in terms of calls
      # to these agents.
      supervisor(Shipping.HandlingEventAgent, []),
      supervisor(Shipping.CargoAgent, []),
    ], strategy: :one_for_one, name: Shipping.Supervisor)
  end

  @doc """
  Set up a resource cache and return the path to that resource file.
  Depending on the running environment (Mix.env) copy (or not) the files
  from the resources directory into appropriate enviornment directory
  """
  def prepare_cache(resource_file_name) do
    resource_dir = Application.get_env(:shipping, :resources_cache)
    resource_file_path = Path.join(resource_dir, resource_file_name)
    case Mix.env do
      # In the development environment, only copy this file if it doesn't
      # exist. This way, any activity is preserved between running of the app.
      :dev ->
        dev_dir = Application.get_env(:shipping, :dev_resources_cache)
        # Create the directory if not there
        if not File.exists?(dev_dir) do
          File.mkdir!(dev_dir)
        end
        dev_file_path = Path.join(dev_dir, resource_file_name)
        if not File.exists?(dev_file_path) do
          File.copy!(resource_file_path, dev_file_path)
        end
        dev_file_path
      # In the testing environment, always copy this file to its testing
      # directory so that tests can run correctly.
      :test ->
        test_dir = Application.get_env(:shipping, :test_resources_cache)
        # Create the directory if not there
        if not File.exists?(test_dir) do
          File.mkdir!(test_dir)
        end
        test_file_path = Path.join(test_dir, resource_file_name)
        File.copy!(resource_file_path, test_file_path)
        test_file_path
    end
  end

end
