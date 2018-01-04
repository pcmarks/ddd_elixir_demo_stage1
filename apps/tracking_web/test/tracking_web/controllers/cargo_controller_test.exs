defmodule TrackingWeb.CargoControllerTest do
  use TrackingWeb.ConnCase

  test "GET /tracking/clerks/cargoes aka show by tracking id - Not Found", %{conn: conn} do
    conn = get(conn, "/tracking/clerks/cargoes", %{"cargo_params" => %{"tracking_id" => "FOO"}})
    assert html_response(conn, 302) =~ "You are being"
  end

  test "GET /tracking/clerks/cargoes aka show by tracking id - Found", %{conn: conn} do
    conn = get(conn, "/tracking/clerks/cargoes", %{"cargo_params" => %{"tracking_id" => "ABC123"}})
    assert html_response(conn, 200) =~ "ABC123"
  end

end
