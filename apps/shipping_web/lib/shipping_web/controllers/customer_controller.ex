defmodule ShippingWeb.CustomerController do
  use ShippingWeb,  :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
