defmodule TrackingWeb.PageView do
  use TrackingWeb, :view

  def render "index.json", _params do
    %{ status: "ready"}
  end
end
