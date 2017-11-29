defmodule ShippingWeb.ClerkView do
  use ShippingWeb, :view

  def render "index.json", _params do
    %{"status": "ok"}
  end
end
