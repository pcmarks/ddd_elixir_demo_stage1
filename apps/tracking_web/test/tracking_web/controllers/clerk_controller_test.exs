defmodule TrackingWeb.ClerkControllerTest do
  use TrackingWeb.ConnCase

  test "GET /tracking/clerks", %{conn: conn} do
    conn = get(conn, "/tracking/clerks")
    assert html_response(conn, 200) =~ "Tracking Number (e.g. ABC123"
    assert html_response(conn, 200) =~ "Track!"
  end
end
