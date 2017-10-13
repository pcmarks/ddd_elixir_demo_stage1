defmodule ShippingWeb.ElmPageView do
  use ShippingWeb, :view

  def render "elm-page.html", _params do
    %{ status: "ready"}
  end

end
