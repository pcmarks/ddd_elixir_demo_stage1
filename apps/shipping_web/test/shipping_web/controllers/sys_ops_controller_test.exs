defmodule ShippingWeb.SysOpsControllerTest do
  use ShippingWeb.ConnCase

  test "GET /shipping/sysops", %{conn: conn} do
    conn = get(conn, "/shipping/sysops")
    assert html_response(conn, 200) =~ "Search"
  end
end
