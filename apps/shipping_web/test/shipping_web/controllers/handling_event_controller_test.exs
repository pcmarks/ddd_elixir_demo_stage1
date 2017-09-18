defmodule ShippingWeb.HandlingEventControllerTest do
  use ShippingWeb.ConnCase

  test "GET /events", %{conn: conn} do
    conn = get(conn, "/events")
    assert html_response(conn, 200) =~ "ABC123"
  end
  test "GET /events/new", %{conn: conn} do
    conn = get(conn, "/events/new")
    assert html_response(conn, 200) =~ "New Handling Event"
  end
end
