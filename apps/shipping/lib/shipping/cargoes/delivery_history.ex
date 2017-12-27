defmodule Shipping.Cargoes.DeliveryHistory do
  @moduledoc """
  VALUE
  A Delivery History structure contains the status of the cargo shipment. Its values
  are largely determined by the cargo's history of handling events.

  For Stage 1, we assume that the cargo has already been "ROUTED", it
  is *not* misdirected and that its initial transportation status is "NOT RECEIVED"
  """
  defstruct [
    transportation_status: "NOT RECEIVED",
    location: "",           # Current Location
    voyage: "",             # Current Voyage
    misdirected: False,
    routing_status: "ROUTED",
  ]

end
