defmodule ShippingWeb.OpsManagerController do
  use ShippingWeb, :controller

  def index(conn, _params) do
    render conn, :index
  end
end