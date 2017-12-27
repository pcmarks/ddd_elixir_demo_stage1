defmodule Shipping.Cargoes.DeliveryTest do
  use ExUnit.Case

  alias Shipping.Cargoes.Delivery
  alias Shipping.HandlingEvents

  test "Create Delivery for existing Cargo" do
    handling_events = HandlingEvents.get_all_with_tracking_id!("ABC123")
    delivery = Shipping.create_delivery(handling_events)
    assert delivery.transportation_status == "IN PORT"
  end

  test "Create Delivery for non-existing Cargo" do
    handling_events = HandlingEvents.get_all_with_tracking_id!("FOO")
    delivery = Shipping.create_delivery(handling_events)
    assert delivery.transportation_status == "NOT RECEIVED"
  end

end
