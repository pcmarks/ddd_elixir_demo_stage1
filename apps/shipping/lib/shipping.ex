defmodule Shipping do
  @moduledoc """
  Shipping keeps the contexts (aggregates) that define your domain and business logic.

  Contexts (aggregates) are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  #############################################################################
  # Support for HandlingEvent types - Useful for UI selects
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


  # State transistions to determine a cargo's transportation status based on
  # a handling event and its current status.
  # NOTE: This may not be a complete set of transitions
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
