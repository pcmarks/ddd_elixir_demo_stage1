defmodule ShippingWeb.HandlingEventController do
  @moduledoc """
  Support for displaying Handling Events, primarily for the Clersk.

  NOTE: Commented out code can be used to create a new Handling Event for
  future demo stages.
  """
  use ShippingWeb,  :controller

  # The Aggregates
  alias Shipping.{HandlingEvents}
  # # The broadcasting channel
  # alias ShippingWeb.HandlingEventChannel

  def show(conn, _params) do
    handling_events = HandlingEvents.list_handling_events()

    # NOTE: Because we are employing a single page view for the Clerk page,
    # we render the ClerkView index page passing a cargo and its handling events
    case get_format(conn) do
      "json" ->
        render(conn, :show, handling_events: handling_events)
      _ ->
        render(conn, ShippingWeb.OpsManagerView, :index,
                    handling_events: handling_events)
    end
  end

end
