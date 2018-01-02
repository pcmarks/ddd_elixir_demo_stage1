defmodule TrackingWeb.OpsManagerController do
  use TrackingWeb, :controller

  def index(conn, _params) do
    render conn, :index
  end
end
