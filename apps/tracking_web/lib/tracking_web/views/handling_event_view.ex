defmodule TrackingWeb.HandlingEventView do
  @moduledoc """
  This view is only responsible for rendering (formatting) a JSON
  HandlingEvent response to a JSON request.
  """
  use TrackingWeb, :view

  def render("show.json",  %{handling_events: handling_events}) do
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

end
