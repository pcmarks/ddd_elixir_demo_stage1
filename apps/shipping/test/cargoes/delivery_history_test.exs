defmodule Shipping.Cargoes.DeliveryHistoriesTest do
  use ExUnit.Case

  alias Shipping.Cargoes.DeliveryHistories

  test "Fetch some existing Delivery History" do
    history = DeliveryHistories.for_tracking_id("ABC123")
    assert length(history) >= 3
  end

  test "Fetch some non-existing Delivery History" do
    history = DeliveryHistories.for_tracking_id("FOO")
    assert history == []
  end

end
