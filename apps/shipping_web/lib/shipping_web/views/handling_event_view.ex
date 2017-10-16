defmodule ShippingWeb.HandlingEventView do
  use ShippingWeb, :view

  def render("index.json",  %{handling_events: handling_events}) do
    %{
      handling_events: Enum.map(handling_events, &handling_event_to_json/1)
      }
  end
  def handling_event_to_json(handling_event) do
    %{location: handling_event.location,
      tracking_id: handling_event.tracking_id,
      completion_time: handling_event.completion_time,
      registration_time: handling_event.registration_time,
      type: handling_event.type,
      voyage: handling_event.voyage
    }
  end

  def render("new.json", %{changeset: changeset,
                          location_map: location_map,
                          handling_event_type_map: handling_event_type_map}) do
    %{location_map: location_map, handling_event_type_map: handling_event_type_map}
  end

end
