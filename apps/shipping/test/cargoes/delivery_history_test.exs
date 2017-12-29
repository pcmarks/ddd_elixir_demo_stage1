defmodule Shipping.Cargoes.DeliveryHistoryTest do
  use ExUnit.Case

  alias Shipping.Cargoes
  alias Shipping.HandlingEvents

  test "Create DeliveryHistory for existing Cargo" do
    handling_events = HandlingEvents.get_all_with_tracking_id!("ABC123")
    delivery = Cargoes.create_delivery_history(handling_events)
    assert delivery.transportation_status == "IN PORT"
  end

  test "Create DeliveryHistory for non-existing Cargo" do
    handling_events = HandlingEvents.get_all_with_tracking_id!("FOO")
    delivery = Cargoes.create_delivery_history(handling_events)
    assert delivery.transportation_status == "NOT RECEIVED"
  end

end
