defmodule Shipping.Cargoes.DeliveryHistoryTest do
  use ExUnit.Case

  alias Shipping.Cargoes.DeliveryHistory

  test "Fetch some existing Delivery History" do
    history = DeliveryHistory.for_tracking_id("ABC123")
    assert length(history) == 3
  end

  test "Fetch some non-existing Delivery History" do
    history = DeliveryHistory.for_tracking_id("FOO")
    assert history == []
  end

end
