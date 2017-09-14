defmodule ShippingWeb.CustomerControllerTest do
  use ShippingWeb.ConnCase

  test "GET /customers", %{conn: conn} do
    conn = get(conn, "/customers")
    assert html_response(conn, 200) =~ "Tracking Number (e.g. ABC123"
    assert html_response(conn, 200) =~ "Track!"
  end
end
