defmodule Shipping do
  @moduledoc """
  Shipping - a Phoenix application - represents the DDD domain model* of the Shipping
  demo. It encapsulates aggregates (see below). This module also contains
  domain-wide business logic and functions.

  Phoenix contexts serve as DDD aggregates*. Aggregates are defined in separate
  modules; they are responsible for the management of data . The aggregates are
  Cargoes and HandlingEvents.

  * From the DDD book: [An aggregate is] a cluster of associated objects that are
  treated as a unit for the purpose of data changes...
  """

  #############################################################################
  # Support for HandlingEvent types - Useful for UI selects, possibly
  #############################################################################
  @handling_event_type_map %{
    "Load": "LOAD",
    "Unload": "UNLOAD",
    "Receive": "RECEIVE",
    "Claim": "CLAIM",
    "Customs": "CUSTOMS"
  }

  def handling_event_type_map do
    @handling_event_type_map
  end


  #############################################################################
  # State transistion function that determines a cargo's transportation
  # status based on a new handling event and its current status.
  # NOTE: This may not be a complete set of transitions
  #############################################################################
  def next_trans_status("RECEIVE", "NOT RECEIVED"), do: "IN PORT"
  def next_trans_status("CUSTOMS", "IN PORT"), do: "IN PORT"
  def next_trans_status("CLAIM", "IN PORT"), do: "CLAIMED"
  def next_trans_status("LOAD", "CLEARED"), do: "ON CARRIER"
  def next_trans_status("LOAD", "RECEIVED"), do: "ON CARRIER"
  def next_trans_status("LOAD", "IN PORT"), do: "ON CARRIER"
  def next_trans_status("LOAD", "ON CARRIER"), do: "ON CARRIER"
  def next_trans_status("UNLOAD", "ON CARRIER"), do: "IN PORT"
  def next_trans_status("UNLOAD", "IN PORT"), do: "IN PORT"
  def next_trans_status(_, status), do: status

end
