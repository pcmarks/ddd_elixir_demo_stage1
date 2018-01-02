defmodule TrackingWeb.ElmPageView do
  use TrackingWeb, :view

  def render "elm-page.html", _params do
    %{ status: "ready"}
  end

end
