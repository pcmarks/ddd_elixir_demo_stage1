defmodule TrackingWeb.ElmPageController do
  use TrackingWeb,  :controller

  plug :put_layout, "elm-page.html"
  
  def index(conn, _params) do
    render conn, "index.html"
  end

end
