defmodule Shipping.Locations do
  @moduledoc """
  A place to hold the names of Locations
  """

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

end
