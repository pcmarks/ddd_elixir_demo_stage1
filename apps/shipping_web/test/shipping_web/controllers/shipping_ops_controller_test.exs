defmodule ShippingWeb.ShippingOpsControllerTest do
  use ShippingWeb.ConnCase

  test "GET /shipping/shippingops", %{conn: conn} do
    conn = get(conn, "/shipping/shippingops")
    assert html_response(conn, 200) =~ "Search"
  end
end
