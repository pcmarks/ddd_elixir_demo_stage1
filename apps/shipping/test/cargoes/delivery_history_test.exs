defmodule Shipping.Cargoes.DeliveryHistoryTest do
  use ExUnit.Case

  alias Shipping.Cargoes.DeliveryHistory
  alias Shipping.Cargoes.Cargo
  alias Shipping.CargoAgent
  alias Shipping.HandlingEvents.HandlingEvent
  alias Shipping.HandlingEventAgent


  test "Fetch some existing Delivery History" do
    history = DeliveryHistory.for_tracking_id("ABC123")
    assert length(history) >= 3
  end

  test "Fetch some non-existing Delivery History" do
    history = DeliveryHistory.for_tracking_id("FOO")
    assert history == []
  end

end
