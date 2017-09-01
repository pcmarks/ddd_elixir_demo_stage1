defmodule Shipping.Cargoes.DeliveryHistory do

  alias Shipping.Repo
  alias Shipping.HandlingEvents.HandlingEvent

  def for_tracking_id(tracking_id) do
    Repo.get_by_tracking_id!(HandlingEvent, tracking_id)
  end
end
