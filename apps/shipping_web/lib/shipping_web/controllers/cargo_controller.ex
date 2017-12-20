defmodule ShippingWeb.CargoController do
  use ShippingWeb, :controller

  alias Shipping.Cargoes

  def show(conn, %{"cargo_params" => %{"tracking_id" => tracking_id}}) do
    case Cargoes.get_cargo_by_tracking_id!(tracking_id) do
      nil ->
        error_formatter(conn, tracking_id)
      %Shipping.Cargoes.Cargo{} = cargo ->
        # Retrieve and apply all handling events to date against the cargo so as
        # to determine the cargo's current status.  Apply oldest events first.
        # The cargo is updated. The tracking status (:on_track, :off_track)
        # is ignored for now.
        handling_events = Cargoes.get_delivery_history_for_tracking_id(cargo.tracking_id)
        {_, updated_cargo} =
          case handling_events do
            [] -> {:on_track, cargo}
            _  ->
              handling_events
              |> Enum.reverse()
              |> Shipping.update_cargo_status()
          end
          # NOTE: Because we are employing a single page view for the Clerk page,
          # we render the ClerkView index page passing a cargo and its handling events
          case get_format(conn) do
            "json" ->
              render(conn, :show, cargo: updated_cargo, handling_events: handling_events)
            _ ->
            render(conn, ShippingWeb.ClerkView, :index,
                          cargo: updated_cargo, handling_events: handling_events)
          end
      _ ->
        conn
          |> put_flash(:error, "Invalid tracking number")
          |> redirect(to: clerk_path(conn, :index))
    end
  end

  defp error_formatter(conn, tracking_id) do
    case get_format(conn) do
      "json" ->
          render(conn, :error, error_status: "Cargo for #{tracking_id} not found.")
      _ ->
        conn
          |> put_flash(:error, "Cargo for #{tracking_id} not found.")
          |> redirect(to: clerk_path(conn, :index))
    end
  end
end
