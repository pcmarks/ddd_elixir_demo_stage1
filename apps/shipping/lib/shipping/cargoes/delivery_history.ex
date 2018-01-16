defmodule Shipping.Cargoes.DeliveryHistory do
  @moduledoc """

  A member of the Cargoes AGGREGATE*.

  A Delivery History structure contains the status of the cargo shipment. Its values
  are largely determined by the cargo's history of handling events. It is part
  of the Cargoes Aggregate.

  For Stage 1, we assume that the cargo has already been "ROUTED", it
  is *not* misdirected and that its initial transportation status is "NOT RECEIVED"

  From the DDD book: [An AGGREGATE is] a cluster of associated objects that
  are treated as a unit for the purgpose of data changes. External references are
  restricted to one member of the AGGREGATE, designated as the root.

  """
  defstruct [
    transportation_status: "NOT RECEIVED",
    location: "UNKNOWN",           # Current Location
    voyage: "",             # Current Voyage
    misdirected: False,
    routing_status: "ROUTED",
  ]

end
