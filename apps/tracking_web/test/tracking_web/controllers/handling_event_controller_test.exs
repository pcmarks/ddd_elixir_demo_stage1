defmodule TrackingWeb.HandlingEventControllerTest do
  use TrackingWeb.ConnCase

  test "GET /shipping/opsmanagers/events", %{conn: conn} do
    conn = get(conn, "/shipping/opsmanagers/events")
    assert html_response(conn, 200) =~ "ABC123"
    assert html_response(conn, 200) =~ "IJK456"
  end
end
