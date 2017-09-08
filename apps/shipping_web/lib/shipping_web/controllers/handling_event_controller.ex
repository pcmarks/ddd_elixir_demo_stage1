defmodule ShippingWeb.HandlingEventController do
  use ShippingWeb,  :controller

  # The Aggregates
  alias Shipping.{Cargoes, HandlingEvents, Locations}
  # The broadcasting channel
  alias ShippingWeb.HandlingEventChannel

  def index(conn, _params) do
    handling_events = HandlingEvents.list_handling_events()
    render(conn, "index.html", handling_events: handling_events)
  end
  def new(conn, _params) do
    changeset = HandlingEvents.change_handling_event(%HandlingEvents.HandlingEvent{})
    render(conn, "new.html", changeset: changeset,
                          location_map: Locations.location_map(),
                          handling_event_type_map: Cargoes.handling_event_type_map())
  end

  def create(conn, %{"handling_event" => handling_event_params}) do
    case HandlingEvents.create_handling_event(handling_event_params) do
      {:ok, handling_event} ->
        # Let everyone who has subscribed  know about the new handling event.
        # Determine a cargo's new status given this handling event. Update the cargo
        # Let everyone who has subscribed know the change in the cargo's status.
        # The tracking status is ignored for now.
        {tracking_status, updated_cargo} =
          handling_event
          |> HandlingEventChannel.broadcast_new_handling_event()
          |> Cargoes.update_cargo_status()
          |> HandlingEventChannel.broadcast_new_cargo_status()
        conn
          |> put_flash(:info, "Handling event created successfully.")
          |> redirect(to: handling_event_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset,
                                location_map: Locations.location_map(),
                                handling_event_type_map: Cargoes.handling_event_type_map())
    end
  end

end
