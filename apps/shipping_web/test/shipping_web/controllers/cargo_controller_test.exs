defmodule ShippingWeb.CargoControllerTest do
  use ShippingWeb.ConnCase

  test "POST /customers aka search by tracking id - Not Found", %{conn: conn} do
    conn = post(conn, "/customers", [search: [tracking_id: "FOO"]])
    assert html_response(conn, 302) =~ "You are being"
  end

  test "POST /customers aka search by tracking id - Found", %{conn: conn} do
    conn = post(conn, "/customers", [search: [tracking_id: "ABC123"]])
    assert html_response(conn, 200) =~ "ABC123"
  end

  test "GET /cargoes by tracking id - Not Found ", %{conn: conn} do
    conn = get(conn, "/cargoes", [tracking_id: "FOO"])
    assert html_response(conn, 302) =~ "You are being"
  end

  test "GET /cargoes by tracking id - Found ", %{conn: conn} do
    conn = get(conn, "/cargoes", [tracking_id: "ABC123"])
    assert html_response(conn, 200) =~ "ABC123"
  end

end
