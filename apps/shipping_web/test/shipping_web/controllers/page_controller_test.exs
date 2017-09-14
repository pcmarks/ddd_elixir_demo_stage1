defmodule ShippingWeb.PageControllerTest do
  use ShippingWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Customers"
    assert html_response(conn, 200) =~ "Handlers"
  end
end
