defmodule Iris.AccountsTest do
  use Iris.DataCase

  alias Iris.Accounts

  import Iris.AccountsFixtures

  describe "invites" do
    alias Iris.Accounts.Invite

    import Iris.AccountsFixtures

    @invalid_attrs %{used: nil, valid_until: nil}

    test "list_invites/0 returns all invites" do
      invite = invite_fixture()
      assert Accounts.list_invites() == [invite]
    end

    test "get_invite!/1 returns the invite with given id" do
      invite = invite_fixture()
      assert Accounts.get_invite!(invite.id) == invite
    end

    test "create_invite/1 with valid data creates a invite" do
      valid_attrs = %{used: true, valid_until: ~U[2024-07-11 22:08:00Z]}

      assert {:ok, %Invite{} = invite} = Accounts.create_invite(valid_attrs)
      assert invite.used == true
      assert invite.valid_until == ~U[2024-07-11 22:08:00Z]
    end

    test "create_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_invite(@invalid_attrs)
    end

    test "update_invite/2 with valid data updates the invite" do
      invite = invite_fixture()
      update_attrs = %{used: false, valid_until: ~U[2024-07-12 22:08:00Z]}

      assert {:ok, %Invite{} = invite} = Accounts.update_invite(invite, update_attrs)
      assert invite.used == false
      assert invite.valid_until == ~U[2024-07-12 22:08:00Z]
    end

    test "update_invite/2 with invalid data returns error changeset" do
      invite = invite_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_invite(invite, @invalid_attrs)
      assert invite == Accounts.get_invite!(invite.id)
    end

    test "delete_invite/1 deletes the invite" do
      invite = invite_fixture()
      assert {:ok, %Invite{}} = Accounts.delete_invite(invite)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_invite!(invite.id) end
    end

    test "change_invite/1 returns a invite changeset" do
      invite = invite_fixture()
      assert %Ecto.Changeset{} = Accounts.change_invite(invite)
    end
  end
end
