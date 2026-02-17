defmodule CloseTheLoopWeb.PageControllerTest do
  use CloseTheLoopWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = html_response(conn, 200)
    assert html =~ "CloseTheLoop"
    assert html =~ "close the loop with one text message"
  end

  test "marketing pages render", %{conn: conn} do
    conn = get(conn, ~p"/how-it-works")
    assert html_response(conn, 200) =~ "How it works"

    conn = get(conn, ~p"/pricing")
    assert html_response(conn, 200) =~ "Pricing"

    conn = get(conn, ~p"/privacy")
    assert html_response(conn, 200) =~ "Privacy"

    conn = get(conn, ~p"/terms")
    assert html_response(conn, 200) =~ "Terms"
  end
end
