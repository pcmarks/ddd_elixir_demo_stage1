defmodule ShippingWeb.HandlerControllerTest do
  use ShippingWeb.ConnCase

  test "GET /handlers", %{conn: conn} do
    conn = get(conn, "/handlers")
    assert html_response(conn, 302) =~ "redirected"
  end
end
