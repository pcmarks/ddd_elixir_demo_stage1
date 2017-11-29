defmodule ShippingWeb.CargoView do
  @moduledoc """
  This view is only responsible for rendering (formatting) a JSON
  Cargo response to a JSON request.
  """
  use ShippingWeb, :view

  def render("error.json", %{error_status: error_status}) do
    %{error_status: error_status}
  end

  def render("show.json", %{cargo: cargo, handling_events: handling_events}) do
    %{cargo:
      %{tracking_id: cargo.tracking_id,
        status: cargo.status,
        handling_events:
          case List.first(handling_events) do
            nil -> nil
            _ ->
              Enum.map(handling_events, &handling_event_to_json/1)
          end
      }
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
