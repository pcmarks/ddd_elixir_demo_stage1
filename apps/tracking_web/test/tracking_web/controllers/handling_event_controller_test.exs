defmodule TrackingWeb.HandlingEventControllerTest do
  use TrackingWeb.ConnCase

  test "GET /tracking/opsmanagers/events", %{conn: conn} do
    conn = get(conn, "/tracking/opsmanagers/events")
    assert html_response(conn, 200) =~ "ABC123"
    assert html_response(conn, 200) =~ "IJK456"
  end
end
