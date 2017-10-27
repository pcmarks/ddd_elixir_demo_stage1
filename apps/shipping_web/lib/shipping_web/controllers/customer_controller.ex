defmodule ShippingWeb.CustomerController do
  use ShippingWeb,  :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  # def search(conn, %{"search" => %{"tracking_id" => tracking_id}}) do
  #   redirect(conn, to: cargo_path(conn, :show, tracking_id))
  # end
 
end
