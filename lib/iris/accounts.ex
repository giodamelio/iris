defmodule Iris.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Iris.Repo

  alias Iris.Accounts.Invite

  @doc """
  Returns the list of invites.

  ## Examples

      iex> list_invites()
      [%Invite{}, ...]

  """
  def list_invites do
    Repo.all(Invite)
  end

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the Invite does not exist.

  ## Examples

      iex> get_invite!(123)
      %Invite{}

      iex> get_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invite!(id), do: Repo.get!(Invite, id)

  @doc """
  Gets a single invite by it's external_id

  Raises `Ecto.NoResultsError` if the Invite does not exist.

  ## Examples

      iex> get_invite_external_id!("108722d0-6492-475c-8696-d04758328d48")
      %Invite{}

      iex> get_invite_external_id!("00000000-00000000-00000000-00000000")
      ** (Ecto.NoResultsError)

  """
  def get_invite_external_id!(id), do: Repo.get_by!(Invite, external_id: id)

  @doc """
  Creates a invite.

  ## Examples

      iex> create_invite(%{field: value})
      {:ok, %Invite{}}

      iex> create_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite(attrs \\ %{}) do
    %Invite{}
    |> Invite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invite.

  ## Examples

      iex> update_invite(invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> update_invite(invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite(%Invite{} = invite, attrs) do
    invite
    |> Invite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invite.

  ## Examples

      iex> delete_invite(invite)
      {:ok, %Invite{}}

      iex> delete_invite(invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite(%Invite{} = invite) do
    Repo.delete(invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite changes.

  ## Examples

      iex> change_invite(invite)
      %Ecto.Changeset{data: %Invite{}}

  """
  def change_invite(%Invite{} = invite, attrs \\ %{}) do
    Invite.changeset(invite, attrs)
  end

  alias Iris.Accounts.User

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

  alias Iris.Accounts.UserInvite

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
  Creates a user_invite.

  ## Examples

      iex> create_user_invite(%{field: value})
      {:ok, %UserInvite{}}

      iex> create_user_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_invite(attrs \\ %{}) do
    %UserInvite{}
    |> UserInvite.changeset(attrs)
    |> Repo.insert()
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
end
