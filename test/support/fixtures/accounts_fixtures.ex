defmodule Iris.AccountsFixtures do
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
end
