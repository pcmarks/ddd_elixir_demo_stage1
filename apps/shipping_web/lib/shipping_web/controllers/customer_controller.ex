defmodule ShippingWeb.CustomerController do
  use ShippingWeb,  :controller

  def index(conn, _params) do
    render conn, :index
  end

  def show(conn, %{"id" => id}) do
    render conn, :index, id: id
  end

end
