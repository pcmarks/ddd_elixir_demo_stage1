defmodule ShippingWeb.ElmPageController do
  use ShippingWeb,  :controller

  plug :put_layout, "elm-page.html"
  
  def index(conn, _params) do
    render conn, "index.html"
  end

end
