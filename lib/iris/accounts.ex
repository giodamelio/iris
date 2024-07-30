defmodule Iris.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Iris.Accounts.PasskeyInvite
  alias Iris.Accounts.User
  alias Iris.Accounts.UserInvite
  alias Iris.Repo

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the count of users.

  ## Examples

      iex> count_users()
      1

  """
  def count_users do
    Repo.aggregate(User, :count, :id)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns the list of user_invites.

  ## Examples

      iex> list_user_invites()
      [%UserInvite{}, ...]

  """
  def list_user_invites do
    Repo.all(UserInvite)
  end

  @doc """
  Returns the count of user_invites

  ## Examples

      iex> count_user_invites()
      1

  """
  def count_user_invites do
    Repo.aggregate(UserInvite, :count, :id)
  end

  @doc """
  Returns the count of user_invites split up by used or not

  ## Examples

      iex> count_user_invites_by_valid()
      %{false: 1, true: 10}

  """
  def count_user_invites_by_valid do
    query =
      from ui in UserInvite,
        group_by: ui.used,
        select: %{ui.used => count(ui.id)}

    query
    |> Repo.all()
    |> Enum.reduce(%{false: 0, true: 0}, &Map.merge(&2, &1))
  end

  @doc """
  Gets a single user_invite.

  Raises `Ecto.NoResultsError` if the User invite does not exist.

  ## Examples

      iex> get_user_invite!(123)
      %UserInvite{}

      iex> get_user_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_invite!(id), do: Repo.get!(UserInvite, id)

  @doc """
  Gets a single user_invite by it's external id

  Returns nil if the User invite does not exist.

  ## Examples

      iex> get_user_invite_by_external_id("108c8fc3-5f53-45e0-b41c-70fa1c9eff10")
      %UserInvite{}

      iex> get_user_invite_by_external_id("e79d9001-6b9a-437d-9a28-a9861b797689")
      nil

  """
  def get_user_invite_by_external_id(id) do
    query = from ui in UserInvite, where: ui.external_id == ^id
    Repo.one(query)
  end

  @doc """
  Checks if a user_invite is valid

  ## Examples

      iex> user_invite_valid?(%UserInvite{used: false})
      true

      iex> user_invite_valid?(%UserInvite{used: true})
      false

  """
  def user_invite_valid?(%UserInvite{} = invite) do
    not Repo.get!(UserInvite, invite.id).used
  end

  @doc """
  Creates a user_invite.

  ## Examples

      iex> create_user_invite(%{field: value})
      {:ok, %UserInvite{}}

      iex> create_user_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_invite do
    Repo.insert(%UserInvite{external_id: Ecto.UUID.generate(), used: false})
  end

  @doc """
  Updates a user_invite.

  ## Examples

      iex> update_user_invite(user_invite, %{field: new_value})
      {:ok, %UserInvite{}}

      iex> update_user_invite(user_invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_invite(%UserInvite{} = user_invite, attrs) do
    user_invite
    |> UserInvite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Invalidates all user invites

  ## Examples

      iex> invalidate_all_user_invites()
      :ok

  """
  def invalidate_all_user_invites do
    Repo.update_all(UserInvite, set: [used: true])
    :ok
  end

  @doc """
  Deletes a user_invite.

  ## Examples

      iex> delete_user_invite(user_invite)
      {:ok, %UserInvite{}}

      iex> delete_user_invite(user_invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_invite(%UserInvite{} = user_invite) do
    Repo.delete(user_invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_invite changes.

  ## Examples

      iex> change_user_invite(user_invite)
      %Ecto.Changeset{data: %UserInvite{}}

  """
  def change_user_invite(%UserInvite{} = user_invite, attrs \\ %{}) do
    UserInvite.changeset(user_invite, attrs)
  end

  @doc """
  Creates a user, but only if there is a valid invites

  This happens inside a transaction so it is all atomic

  ## Examples

      iex> create_user(%{field: value}, %UserInvite{used: false})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value}, %UserInvite{used: true})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_from_invite(attrs \\ %{}, %UserInvite{} = invite) do
    Repo.transaction(fn ->
      # Rollback if invite is invalid
      if not user_invite_valid?(invite) do
        Repo.rollback(:invalid_invite)
      end

      # Create user
      user =
        case create_user(attrs) do
          {:ok, user} -> user
          {:error, error} -> Repo.rollback(error)
        end

      # Invalidate user invite
      invalid_invite =
        case update_user_invite(invite, %{used: true}) do
          {:ok, updated_invite} -> updated_invite
          {:error, error} -> Repo.rollback(error)
        end

      {user, invalid_invite}
    end)
  end

  @doc """
  Returns the list of passkey_invites.

  ## Examples

      iex> list_passkey_invites()
      [%PasskeyInvite{}, ...]

  """
  def list_passkey_invites do
    PasskeyInvite
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Returns the count of passkey_invites.

  ## Examples

      iex> count_passkey_invites()
      1

  """
  def count_passkey_invites do
    Repo.aggregate(PasskeyInvite, :count, :id)
  end

  @doc """
  Gets a single passkey_invite.

  Raises `Ecto.NoResultsError` if the Passkey invite does not exist.

  ## Examples

      iex> get_passkey_invite!(123)
      %PasskeyInvite{}

      iex> get_passkey_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_passkey_invite!(id) do
    PasskeyInvite
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single passkey_invite by it's external id

  Returns nil if the User invite does not exist.

  ## Examples

      iex> get_passkey_invite_by_external_id("108c8fc3-5f53-45e0-b41c-70fa1c9eff10")
      %UserInvite{}

      iex> get_passkey_invite_by_external_id("e79d9001-6b9a-437d-9a28-a9861b797689")
      nil

  """
  def get_passkey_invite_by_external_id(id) do
    query = from pi in PasskeyInvite, where: pi.external_id == ^id, preload: :user
    Repo.one(query)
  end

  @doc """
  Creates a passkey_invite.

  ## Examples

      iex> create_passkey_invite(%{field: value})
      {:ok, %PasskeyInvite{}}

      iex> create_passkey_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_passkey_invite(attrs \\ %{}) do
    %PasskeyInvite{}
    |> PasskeyInvite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a passkey_invite.

  ## Examples

      iex> update_passkey_invite(passkey_invite, %{field: new_value})
      {:ok, %PasskeyInvite{}}

      iex> update_passkey_invite(passkey_invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_passkey_invite(%PasskeyInvite{} = passkey_invite, attrs) do
    passkey_invite
    |> PasskeyInvite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a passkey_invite.

  ## Examples

      iex> delete_passkey_invite(passkey_invite)
      {:ok, %PasskeyInvite{}}

      iex> delete_passkey_invite(passkey_invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_passkey_invite(%PasskeyInvite{} = passkey_invite) do
    Repo.delete(passkey_invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking passkey_invite changes.

  ## Examples

      iex> change_passkey_invite(passkey_invite)
      %Ecto.Changeset{data: %PasskeyInvite{}}

  """
  def change_passkey_invite(%PasskeyInvite{} = passkey_invite, attrs \\ %{}) do
    PasskeyInvite.changeset(passkey_invite, attrs)
  end
end
