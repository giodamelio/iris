defmodule IrisWeb.PageControllerTest do
  use IrisWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hello World"
  end
end
