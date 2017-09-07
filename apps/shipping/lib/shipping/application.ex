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
end
