defmodule ShippingWeb.SysOpsController do
  use ShippingWeb, :controller

  @doc """
  Simply redirect this request to a listing of all the handling events.

  As a result, there is no view or templates for clerks.

  In subsequent stages, Clerks will have a screen within whick they can
  specify the cargo that they are handling.
  """
  def index(conn, _params) do
    redirect(conn, to: handling_event_path(conn, :index))
  end
end
