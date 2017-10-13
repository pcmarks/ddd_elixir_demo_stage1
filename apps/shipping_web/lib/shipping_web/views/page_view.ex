defmodule ShippingWeb.PageView do
  use ShippingWeb, :view

  def render "index.json", _params do
    %{ status: "ready"}
  end
end
