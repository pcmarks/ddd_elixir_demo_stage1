defmodule Shipping do
  @moduledoc """
  Shipping keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Shipping.Cargoes.{Cargo, DeliveryHistory}
  alias Shipping.HandlingEvents.HandlingEvent

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

  @doc """
  Create a DeliveryHistory: a representation of the Cargo's current status. The values
  in a DeliveryHistory are determined by applying each of the Cargo's handling events,
  in turn, against the DeliveryHistory.
  """
  def create_delivery_history(handling_events) do
    delivery_history = %DeliveryHistory{}
    update_delivery_history(handling_events, delivery_history)
  end

  defp update_delivery_history([%HandlingEvent{
                          type: type} | handling_events],
                        %DeliveryHistory{
                          transportation_status: trans_status} = delivery_history) do
      new_trans_status = next_trans_status(type, trans_status)
      update_delivery_history(handling_events,
                      %{delivery_history | :transportation_status => new_trans_status})
  end
  defp update_delivery_history([], delivery_history) do
    delivery_history
  end

  # State transistions to determine a cargo's transportation status based on
  # its current status and a handling event.
  # NOTE: Is this a complete set of combinations?
  defp next_trans_status("RECEIVE", "NOT RECEIVED"), do: "IN PORT"
  defp next_trans_status("CUSTOMS", "IN PORT"), do: "IN PORT"
  defp next_trans_status("CLAIM", "IN PORT"), do: "CLAIMED"
  defp next_trans_status("LOAD", "CLEARED"), do: "ON CARRIER"
  defp next_trans_status("LOAD", "RECEIVED"), do: "ON CARRIER"
  defp next_trans_status("LOAD", "IN PORT"), do: "ON CARRIER"
  defp next_trans_status("LOAD", "ON CARRIER"), do: "ON CARRIER"
  defp next_trans_status("UNLOAD", "ON CARRIER"), do: "IN PORT"
  defp next_trans_status("UNLOAD", "IN PORT"), do: "IN PORT"
  defp next_trans_status(_, status), do: status

end
