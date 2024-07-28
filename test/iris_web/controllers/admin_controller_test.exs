defmodule IrisWeb.AdminControllerTest do
  use IrisWeb.ConnCase, async: true

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
      assert response =~ "0 total user invites"
      assert response =~ "0 valid invites"
      assert response =~ "0 used invites"
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
      assert response =~ "6 total user invites"
      assert response =~ "2 valid invites"
      assert response =~ "4 used invites"
    end

    test "generate user invite", %{conn: conn} do
      conn = post(conn, ~p"/admin/user_invites")
      assert redirected_to(conn) == ~p"/admin/user_invites/1"
    end
  end

  describe "show_user_invite" do
    test "display a user invite", %{conn: conn} do
      user_invite = user_invite_fixture()
      conn = get(conn, ~p"/admin/user_invites/#{user_invite.id}")
      assert html_response(conn, 200) =~ "/invite/user/#{user_invite.external_id}"
    end
  end
end
