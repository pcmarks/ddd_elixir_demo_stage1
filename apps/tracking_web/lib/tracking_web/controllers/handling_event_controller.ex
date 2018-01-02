defmodule TrackingWeb.HandlingEventController do
  @moduledoc """
  Support for displaying Handling Events, primarily for the Operations Manager.
  """
  use TrackingWeb,  :controller

  # The Aggregates
  alias Shipping.{HandlingEvents}
  # # The broadcasting channel
  # alias TrackingWeb.HandlingEventChannel

  def show(conn, _params) do
    handling_events = HandlingEvents.list_handling_events()
    render(conn, :show, handling_events: handling_events)
  end

end
