defmodule Iris.AccountsTest do
  use Iris.DataCase, async: true

  import Iris.AccountsFixtures

  alias Iris.Accounts

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

    test "count_user_invites/0 counts properly" do
      user_invite_fixture()
      assert Accounts.count_user_invites() == 1

      user_invite_fixture()
      assert Accounts.count_user_invites() == 2
    end

    test "count_user_invites_by_valid/0 with no invites" do
      assert Accounts.count_user_invites_by_valid() == %{false: 0, true: 0}
    end

    test "count_user_invites_by_valid/0 counts properly" do
      user_invite_fixture()
      invalid_user_invite_fixture()
      invalid_user_invite_fixture()
      assert Accounts.count_user_invites_by_valid() == %{false: 1, true: 2}
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

    test "user_invite_valid?/1 validates unused invite" do
      user_invite = user_invite_fixture()
      assert Accounts.user_invite_valid?(user_invite) == true
    end

    test "user_invite_valid?/1 validates used invite" do
      user_invite = invalid_user_invite_fixture()
      assert Accounts.user_invite_valid?(user_invite) == false
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

    test "invalidate_all_user_invites/0 invalidates all invites" do
      user_invite_fixture()
      user_invite_fixture()
      invalid_user_invite_fixture()
      invalid_user_invite_fixture()

      assert Accounts.count_user_invites_by_valid() == %{false: 2, true: 2}

      assert :ok == Accounts.invalidate_all_user_invites()

      assert Accounts.count_user_invites_by_valid() == %{false: 0, true: 4}
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

  describe "cross resource functions" do
    alias Iris.Accounts.User
    alias Iris.Accounts.UserInvite

    import Iris.AccountsFixtures

    @valid_user_attrs %{email: "some email", full_name: "some full_name"}

    test "create_user_from_invite/2 fails on an invalid invite" do
      invalid_invite = invalid_user_invite_fixture()

      assert Accounts.create_user_from_invite(@valid_user_attrs, invalid_invite) ==
               {:error, :invalid_invite}
    end

    test "create_user_from_invite/2 creates user and invalidates invite" do
      invite = user_invite_fixture()

      {:ok, {user, invite}} = Accounts.create_user_from_invite(@valid_user_attrs, invite)

      assert user.email == @valid_user_attrs.email
      assert user.full_name == @valid_user_attrs.full_name
      assert not Accounts.user_invite_valid?(invite)
    end

    test "create_user_from_invite/2 doesn't invalidate invite on invalid user attrs" do
      invite = user_invite_fixture()

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_from_invite(%{}, invite)
      assert Accounts.user_invite_valid?(invite)
    end
  end

  describe "passkey_invites" do
    alias Iris.Accounts.PasskeyInvite

    import Iris.AccountsFixtures

    @invalid_attrs %{external_id: nil, used: nil}

    test "list_passkey_invites/0 returns all passkey_invites" do
      passkey_invite = passkey_invite_fixture()
      assert Accounts.list_passkey_invites() == [passkey_invite]
    end

    test "get_passkey_invite!/1 returns the passkey_invite with given id" do
      passkey_invite = passkey_invite_fixture()
      assert Accounts.get_passkey_invite!(passkey_invite.id) == passkey_invite
    end

    test "get_passkey_invite_by_external_id/1 returns the user_invite with given external id" do
      passkey_invite = passkey_invite_fixture()

      assert Accounts.get_passkey_invite_by_external_id(passkey_invite.external_id) ==
               passkey_invite
    end

    test "get_passkey_invite_by_external_id/1 returns nil for user that doesn't exist" do
      assert Accounts.get_passkey_invite_by_external_id("7488a646-e31f-11e4-aace-600308960668") ==
               nil
    end

    test "create_passkey_invite/1 with valid data creates a passkey_invite" do
      user = user_fixture()

      valid_attrs = %{
        external_id: "7488a646-e31f-11e4-aace-600308960662",
        used: true,
        user_id: user.id
      }

      assert {:ok, %PasskeyInvite{} = passkey_invite} =
               Accounts.create_passkey_invite(valid_attrs)

      assert passkey_invite.external_id == "7488a646-e31f-11e4-aace-600308960662"
      assert passkey_invite.used == true
    end

    test "create_passkey_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_passkey_invite(@invalid_attrs)
    end

    test "update_passkey_invite/2 with valid data updates the passkey_invite" do
      passkey_invite = passkey_invite_fixture()
      update_attrs = %{external_id: "7488a646-e31f-11e4-aace-600308960668", used: false}

      assert {:ok, %PasskeyInvite{} = passkey_invite} =
               Accounts.update_passkey_invite(passkey_invite, update_attrs)

      assert passkey_invite.external_id == "7488a646-e31f-11e4-aace-600308960668"
      assert passkey_invite.used == false
    end

    test "update_passkey_invite/2 with invalid data returns error changeset" do
      passkey_invite = passkey_invite_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_passkey_invite(passkey_invite, @invalid_attrs)

      assert passkey_invite == Accounts.get_passkey_invite!(passkey_invite.id)
    end

    test "delete_passkey_invite/1 deletes the passkey_invite" do
      passkey_invite = passkey_invite_fixture()
      assert {:ok, %PasskeyInvite{}} = Accounts.delete_passkey_invite(passkey_invite)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_passkey_invite!(passkey_invite.id) end
    end

    test "change_passkey_invite/1 returns a passkey_invite changeset" do
      passkey_invite = passkey_invite_fixture()
      assert %Ecto.Changeset{} = Accounts.change_passkey_invite(passkey_invite)
    end
  end
end
