defmodule Iris.AccountsFixtures do
  @moduledoc false

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        full_name: "some full_name"
      })
      |> Iris.Accounts.create_user()

    user
  end

  @doc """
  Generate a user_invite.
  """
  def user_invite_fixture do
    {:ok, user_invite} = Iris.Accounts.create_user_invite()

    user_invite
  end

  @doc """
  Generate an invalid user_invite.
  """
  def invalid_user_invite_fixture do
    {:ok, user_invite} = Iris.Accounts.create_user_invite()
    {:ok, used_user_invite} = Iris.Accounts.update_user_invite(user_invite, %{used: true})

    used_user_invite
  end

  @doc """
  Generate a passkey_invite.
  """
  def passkey_invite_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, passkey_invite} =
      attrs
      |> Enum.into(%{
        external_id: "7488a646-e31f-11e4-aace-600308960662",
        used: true,
        user_id: user.id
      })
      |> Iris.Accounts.create_passkey_invite()

    Iris.Repo.preload(passkey_invite, :user)
  end
end
