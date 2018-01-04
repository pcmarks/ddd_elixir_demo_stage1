defmodule TrackingWeb.ShippingOpsControllerTest do
  use TrackingWeb.ConnCase

  test "GET /tracking/opsmangers", %{conn: conn} do 
    conn = get(conn, "/tracking/opsmanagers")
    assert html_response(conn, 200) =~ "Search"
  end
end
