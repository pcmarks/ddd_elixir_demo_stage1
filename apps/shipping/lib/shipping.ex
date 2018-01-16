defmodule Shipping do
  @moduledoc """
  Shipping - a Phoenix application (see Shipping.Application) - represents the
  DDD domain model* of the Shipping   demo. It encapsulates two aggregates -
  Phoenix contexts - Cargoes and Handling Events. This module also contains
  domain-wide business logic and functions.

  * From the DDD book: [A model is] a system of abstractions that describes
  selected aspects of a domain and can be used to solve problems related to that
  domain.
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
  # Support for Locations
  #############################################################################
  @location_map  %{
    "Hongkong": "CHHKG",
    "Melbourne": "AUMEL",
    "Stockholm": "SESTO",
    "Helsinki": "FIHEL",
    "Chicago": "USCHI",
    "Tokyo": "JPTKO",
    "Hamburg": "DEHAM",
    "Shanghai": "CNSHA",
    "Rotterdam": "NLRTM",
    "Goteborg": "SEGOT",
    "Hangzhou": "CHHGH",
    "New York": "USNYC",
    "Dallas": "USDAL"
  }

  def location_map do
    @location_map
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
