defmodule Iris.AccountsFixtures do
  @moduledoc false

  @doc """
  Generate a invite.
  """
  def invite_fixture(attrs \\ %{}) do
    {:ok, invite} =
      attrs
      |> Enum.into(%{
        used: true,
        valid_until: ~U[2024-07-11 22:08:00Z]
      })
      |> Iris.Accounts.create_invite()

    invite
  end

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
  def user_invite_fixture() do
    {:ok, user_invite} = Iris.Accounts.create_user_invite()

    user_invite
  end

  @doc """
  Generate an invalid user_invite.
  """
  def invalid_user_invite_fixture() do
    {:ok, user_invite} = Iris.Accounts.create_user_invite()
    {:ok, used_user_invite} = Iris.Accounts.update_user_invite(user_invite, %{used: true})

    used_user_invite
  end
end
