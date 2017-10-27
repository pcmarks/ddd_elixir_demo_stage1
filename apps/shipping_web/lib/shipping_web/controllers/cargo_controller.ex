defmodule ShippingWeb.CargoController do
  use ShippingWeb, :controller

  alias Shipping.Cargoes

  # def search(conn, %{"search" => %{"tracking_id" => tracking_id} = params}) do
  #   case Cargoes.get_cargo_by_tracking_id!(tracking_id) do
  #     nil ->
  #       conn
  #         |> put_flash(:error, "Cargo for #{tracking_id} not found.")
  #         |> redirect(to: customer_path(conn, :index))
  #     _ ->
  #       show(conn, params)
  #   end
  # end

  def show(conn, %{"cargo_params" => %{"tracking_id" => tracking_id}}) do
    case Cargoes.get_cargo_by_tracking_id!(tracking_id) do
      nil ->
        conn
          |> put_flash(:error, "Cargo for #{tracking_id} not found.")
          |> redirect(to: customer_path(conn, :index))
      %Shipping.Cargoes.Cargo{} = cargo ->
        # Retrieve and apply all handling events to date against the cargo so as
        # to determine the cargo's current status.  Apply oldest events first.
        # The cargo is updated. The tracking status (:on_track, :off_track)
        # is ignored for now.
        handling_events = Cargoes.get_delivery_history_for_tracking_id(cargo.tracking_id)
        {tracking_status, updated_cargo} =
          case handling_events do
            [] -> {:on_track, cargo}
            _  ->
              handling_events
              |> Enum.reverse()
              |> Cargoes.update_cargo_status()
          end
          render(conn, :show, cargo: updated_cargo, handling_events: handling_events)
      _ ->
        conn
          |> put_flash(:error, "Invalid tracking number")
          |> redirect(to: customer_path(conn, :index))
    end
  end
end
