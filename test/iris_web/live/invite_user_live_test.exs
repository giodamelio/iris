defmodule IrisWeb.InviteUserLiveTest do
  use IrisWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Iris.AccountsFixtures
  alias Iris.Accounts

  @create_attrs %{email: "some email", full_name: "some full_name"}

  test "creates a user successfully", %{conn: conn} do
    invite = user_invite_fixture()

    {:ok, invite_live, _html} = live(conn, ~p"/invite/user/#{invite.external_id}")

    {:ok, conn} =
      invite_live
      |> form("#user-form", user: @create_attrs)
      |> render_submit()
      |> follow_redirect(conn)

    assert Accounts.count_users() == 1
    assert html_response(conn, 200) =~ "Register Passkey"
  end
end
