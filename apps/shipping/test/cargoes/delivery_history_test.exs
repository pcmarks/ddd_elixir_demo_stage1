defmodule Shipping.Cargoes.DeliveryHistoryTest do
  use ExUnit.Case

  alias Shipping.Cargoes
  alias Shipping.HandlingEvents

  test "Create DeliveryHistory for existing Cargo with a valid transportation status" do
    delivery =
      HandlingEvents.get_all_with_tracking_id!("ABC123")
      |> Enum.reverse()
      |> Cargoes.create_delivery_history()
    assert delivery.transportation_status == "IN PORT"
  end

  test "Create DeliveryHistory with an UNKNOWN transportation status" do
    {_result, _handling_event} = HandlingEvents.create_handling_event(
      %{type: "UNLOAD", location: "USCHI" , completion_time: DateTime.utc_now, registration_time: DateTime.utc_now, tracking_id: "XYYZZY", voyage: "989"})
    delivery_history =
      HandlingEvents.get_all_with_tracking_id!("XYYZZY")
      |> Enum.reverse()
      |> Cargoes.create_delivery_history()
    assert delivery_history.transportation_status == "UNKNOWN"
  end

end
