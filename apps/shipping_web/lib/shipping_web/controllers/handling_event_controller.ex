defmodule ShippingWeb.HandlingEventController do
  @moduledoc """
  Support for displaying Handling Events, primarily for the Operations Manager.
  """
  use ShippingWeb,  :controller

  # The Aggregates
  alias Shipping.{HandlingEvents}
  # # The broadcasting channel
  # alias ShippingWeb.HandlingEventChannel

  def show(conn, _params) do
    handling_events = HandlingEvents.list_handling_events()
    render(conn, :show, handling_events: handling_events)
  end

end
