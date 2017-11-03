defmodule ShippingWeb.CustomerController do
  use ShippingWeb,  :controller

  def index(conn, _params) do
    render conn, :index
  end

  def show(conn, _params) do
    render conn, :index
  end

end
