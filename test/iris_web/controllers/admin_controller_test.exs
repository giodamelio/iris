defmodule IrisWeb.AdminControllerTest do
  use IrisWeb.ConnCase

  import Iris.AccountsFixtures

  describe "index" do
    test "get the count of users with no users", %{conn: conn} do
      conn = get(conn, ~p"/admin")
      assert html_response(conn, 200) =~ "There are 0 users"
    end

    test "get the count of users with 3 users", %{conn: conn} do
      user_fixture()
      user_fixture()
      user_fixture()

      conn = get(conn, ~p"/admin")
      assert html_response(conn, 200) =~ "There are 3 users"
    end

    test "get the count of user invites with no invites", %{conn: conn} do
      conn = get(conn, ~p"/admin")
      response = html_response(conn, 200)
      assert response =~ "0 user invites"
      assert response =~ "0 are still valid"
      assert response =~ "0 have been used"
    end

    test "get the count of user invites with a mix of used and unused", %{conn: conn} do
      user_invite_fixture()
      user_invite_fixture()
      invalid_user_invite_fixture()
      invalid_user_invite_fixture()
      invalid_user_invite_fixture()
      invalid_user_invite_fixture()

      conn = get(conn, ~p"/admin")
      response = html_response(conn, 200)
      assert response =~ "6 user invites"
      assert response =~ "2 are still valid"
      assert response =~ "4 have been used"
    end
  end
end
