defmodule ShippingWeb.OpsManagerController do
  use ShippingWeb, :controller

 @doc """
 Note that we render using the atom :index. Doing so, allows to either render
 a JSON response or an HTML response. (See OpsManagerView)
 """
  def index(conn, _params) do
    render conn, :index
  end
end
