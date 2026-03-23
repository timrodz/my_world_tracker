defmodule WorldTrackerWeb.PageControllerTest do
  use WorldTrackerWeb.ConnCase

  test "GET / renders the dashboard", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = html_response(conn, 200)

    assert html =~ "Major money indicators in one live board"
    assert html =~ "Yahoo Finance"
  end
end
