defmodule Shipping.Cargoes.Delivery do
  @moduledoc """
  A Delivery structure reflects the status of the cargo shipment. Its values
  are determined by the cargo's history of handling events.
  """
  defstruct [
    transportationStatus: "NOT RECEIVED",
    location: "",
    voyage: "",
    misdirected: False,
    routingStatus: "ROUTED"
  ]
end
