defmodule ShippingWeb.HandlingEventChannel do
  use Phoenix.Channel


  def join("handling_event:" <> tracking_id, _message, socket) do
    handling_events = Cargoes.get_delivery_history_for_tracking_id(tracking_id)

    {:ok, assign(socket, :handling_events, handling_events)}
  end

  def handle_in("next_event", _tracking_id, %{assigns: %{handling_events: []}} = socket) do
    {:reply, :ok, socket}
  end
  def handle_in("next_event", _tracking_id, %{assigns: %{handling_events: handling_events}} = socket) do
    [event | events] = handling_events

    broadcast! socket, "next_event", %{
        voyage: event.voyage,
        location: event.location,
        date: DateTime.to_date(event.completion_time),
        time: DateTime.to_time(event.completion_time),
        type: event.type
    }

    {:reply, :ok, assign(socket, :handling_events, events)}
  end

  def broadcast_new_handling_event(handling_event) do
    ShippingWeb.Endpoint.broadcast(
      "handling_event:#{handling_event.tracking_id}",
      "new_handling_event",
      to_map(handling_event))
    handling_event
  end

  def broadcast_new_cargo_status({_tracking_status, cargo} = status_and_cargo) do
    ShippingWeb.Endpoint.broadcast(
      "handling_event:#{cargo.tracking_id}",
      "new_cargo_status",
      %{status: cargo.status})
    status_and_cargo
  end

  defp to_map(handling_event) do
    %{
      voyage: handling_event.voyage,
      location: handling_event.location,
      date: DateTime.to_date(handling_event.completion_time),
      time: DateTime.to_time(handling_event.completion_time),
      type: handling_event.type
    }
  end
end
