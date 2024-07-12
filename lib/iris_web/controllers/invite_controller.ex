defmodule IrisWeb.InviteController do
  use IrisWeb, :controller

  alias Iris.Accounts
  alias Iris.Accounts.Invite

  def index(conn, _params) do
    invites = Accounts.list_invites()
    render(conn, :index, invites: invites)
  end

  def new(conn, _params) do
    changeset = Accounts.change_invite(%Invite{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"invite" => invite_params}) do
    case Accounts.create_invite(invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite created successfully.")
        |> redirect(to: ~p"/admin/invites/#{invite}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invite = Accounts.get_invite!(id)
    render(conn, :show, invite: invite)
  end

  def edit(conn, %{"id" => id}) do
    invite = Accounts.get_invite!(id)
    changeset = Accounts.change_invite(invite)
    render(conn, :edit, invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    invite = Accounts.get_invite!(id)

    case Accounts.update_invite(invite, invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> redirect(to: ~p"/admin/invites/#{invite}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, invite: invite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Accounts.get_invite!(id)
    {:ok, _invite} = Accounts.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: ~p"/admin/invites")
  end
end
