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

    test "get_invite_external_id!/1 returns the invite with given external id" do
      invite = invite_fixture()
      assert Accounts.get_invite_external_id!(invite.external_id) == invite
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

  describe "users" do
    alias Iris.Accounts.User

    import Iris.AccountsFixtures

    @invalid_attrs %{email: nil, full_name: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some email", full_name: "some full_name"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.full_name == "some full_name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some updated email", full_name: "some updated full_name"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.full_name == "some updated full_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "user_invites" do
    alias Iris.Accounts.UserInvite

    import Iris.AccountsFixtures

    @invalid_attrs %{external_id: nil, used: nil}

    test "list_user_invites/0 returns all user_invites" do
      user_invite = user_invite_fixture()
      assert Accounts.list_user_invites() == [user_invite]
    end

    test "get_user_invite!/1 returns the user_invite with given id" do
      user_invite = user_invite_fixture()
      assert Accounts.get_user_invite!(user_invite.id) == user_invite
    end

    test "get_user_invite_by_external_id/1 returns the user_invite with given external id" do
      user_invite = user_invite_fixture()
      assert Accounts.get_user_invite_by_external_id(user_invite.external_id) == user_invite
    end

    test "get_user_invite_by_external_id/1 returns nil for user that doesn't exist" do
      assert Accounts.get_user_invite_by_external_id("7488a646-e31f-11e4-aace-600308960668") ==
               nil
    end

    test "create_user_invite/0 with valid data creates a user_invite" do
      assert {:ok, %UserInvite{} = user_invite} = Accounts.create_user_invite()
      assert user_invite.external_id != nil
      assert user_invite.used == false
    end

    test "update_user_invite/2 with valid data updates the user_invite" do
      user_invite = user_invite_fixture()
      update_attrs = %{external_id: "7488a646-e31f-11e4-aace-600308960668", used: false}

      assert {:ok, %UserInvite{} = user_invite} =
               Accounts.update_user_invite(user_invite, update_attrs)

      assert user_invite.external_id == "7488a646-e31f-11e4-aace-600308960668"
      assert user_invite.used == false
    end

    test "update_user_invite/2 with invalid data returns error changeset" do
      user_invite = user_invite_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_invite(user_invite, @invalid_attrs)

      assert user_invite == Accounts.get_user_invite!(user_invite.id)
    end

    test "delete_user_invite/1 deletes the user_invite" do
      user_invite = user_invite_fixture()
      assert {:ok, %UserInvite{}} = Accounts.delete_user_invite(user_invite)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_invite!(user_invite.id) end
    end

    test "change_user_invite/1 returns a user_invite changeset" do
      user_invite = user_invite_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_invite(user_invite)
    end
  end
end
