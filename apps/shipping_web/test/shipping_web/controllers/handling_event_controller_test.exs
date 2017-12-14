defmodule ShippingWeb.HandlingEventControllerTest do
  use ShippingWeb.ConnCase

  test "GET /shipping/sysops/events", %{conn: conn} do
    conn = get(conn, "/shipping/sysops/events")
    assert html_response(conn, 200) =~ "ABC123"
    assert html_response(conn, 200) =~ "IJK456"
  end
end
