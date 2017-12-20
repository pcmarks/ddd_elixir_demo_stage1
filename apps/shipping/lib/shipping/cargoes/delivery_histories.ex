defmodule Shipping.Cargoes.DeliveryHistories do
  @moduledoc """
  A delivery history for a particular cargo is a list of all of the handling
  events associated with the cargo.
  """
  alias Shipping.Repo
  alias Shipping.HandlingEvents.HandlingEvent

  @doc """
  Retrieve all handling events associated with this tracking id
  """
  def for_tracking_id(tracking_id) do
    Repo.get_by_tracking_id!(HandlingEvent, tracking_id)
  end
end
