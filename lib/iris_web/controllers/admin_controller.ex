defmodule IrisWeb.AdminController do
  use IrisWeb, :controller

  alias Iris.Accounts

  def index(conn, _params) do
    render(conn, :index,
      users_count: Accounts.count_users(),
      user_invites_count: Accounts.count_user_invites()
    )
  end

  def create_user_invite(conn, _params) do
    {:ok, user_invite} = Accounts.create_user_invite()
    redirect(conn, to: ~p"/admin/user_invites/#{user_invite.id}")
  end

  def show_user_invite(conn, params) do
    user_invite = Accounts.get_user_invite!(params["id"])
    render(conn, :show_user_invite, user_invite: user_invite)
  end
end
