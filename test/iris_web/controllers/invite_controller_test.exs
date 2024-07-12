defmodule IrisWeb.InviteControllerTest do
  use IrisWeb.ConnCase

  import Iris.AccountsFixtures

  @create_attrs %{used: true, valid_until: ~U[2024-07-11 22:08:00Z]}
  @update_attrs %{used: false, valid_until: ~U[2024-07-12 22:08:00Z]}
  @invalid_attrs %{used: nil, valid_until: nil}

  describe "index" do
    test "lists all invites", %{conn: conn} do
      conn = get(conn, ~p"/admin/invites")
      assert html_response(conn, 200) =~ "Listing Invites"
    end
  end

  describe "new invite" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/invites/new")
      assert html_response(conn, 200) =~ "New Invite"
    end
  end

  describe "create invite" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/invites", invite: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/invites/#{id}"

      conn = get(conn, ~p"/admin/invites/#{id}")
      assert html_response(conn, 200) =~ "Invite #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/invites", invite: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Invite"
    end
  end

  describe "edit invite" do
    setup [:create_invite]

    test "renders form for editing chosen invite", %{conn: conn, invite: invite} do
      conn = get(conn, ~p"/admin/invites/#{invite}/edit")
      assert html_response(conn, 200) =~ "Edit Invite"
    end
  end

  describe "update invite" do
    setup [:create_invite]

    test "redirects when data is valid", %{conn: conn, invite: invite} do
      conn = put(conn, ~p"/admin/invites/#{invite}", invite: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/invites/#{invite}"

      conn = get(conn, ~p"/admin/invites/#{invite}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, invite: invite} do
      conn = put(conn, ~p"/admin/invites/#{invite}", invite: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Invite"
    end
  end

  describe "delete invite" do
    setup [:create_invite]

    test "deletes chosen invite", %{conn: conn, invite: invite} do
      conn = delete(conn, ~p"/admin/invites/#{invite}")
      assert redirected_to(conn) == ~p"/admin/invites"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/invites/#{invite}")
      end
    end
  end

  defp create_invite(_) do
    invite = invite_fixture()
    %{invite: invite}
  end
end
