defmodule TrackingWeb.CargoController do
  @moduledoc """
  The Tracking Applications Phoenix Controller. It handles both HTML and JSON
  requests, responses including errors.
  """
  use TrackingWeb, :controller

  alias Shipping.{Cargoes, HandlingEvents}
  @doc """
  Prepare to show a Cargo and its associated DeliveryHistory. Rendering results
  as an HTML page or a JSON response.
  """
  def show(conn, %{"cargo_params" => %{"tracking_id" => tracking_id}}) do
    case Cargoes.get_cargo_by_tracking_id!(tracking_id) do
      nil ->
        cargo_error(conn, "Cargo for #{tracking_id} not found.")
      %Shipping.Cargoes.Cargo{} = cargo ->
        # Retrieve and apply all handling events to date against the cargo
        # to determine the cargo's current status (Delivery History).
        # First reverse the Handling Events which are in newest event first order
        # so that the oldest event is first.
        handling_events = HandlingEvents.get_all_with_tracking_id!(cargo.tracking_id)
        delivery_history =
          handling_events
          |> Enum.reverse
          |> Cargoes.create_delivery_history()
        render(conn, :show,
                     cargo: cargo,
                     delivery_history: delivery_history,
                     handling_events: handling_events)
    end
  end

  defp cargo_error(conn, error_msg) do
    case get_format(conn) do
      "json" ->
          render(conn, :error, error_status: error_msg)
      _ ->
        conn
          |> put_flash(:error, error_msg)
          |> redirect(to: clerk_path(conn, :index))
    end
  end
end
