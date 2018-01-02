defmodule TrackingWeb.ShippingOpsControllerTest do
  use TrackingWeb.ConnCase

  test "GET /shipping/opsmangers", %{conn: conn} do
    conn = get(conn, "/shipping/opsmanagers")
    assert html_response(conn, 200) =~ "Search"
  end
end
