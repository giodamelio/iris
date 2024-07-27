defmodule IrisWeb.AdminController do
  use IrisWeb, :controller

  alias Iris.Accounts

  def index(conn, _params) do
    render(conn, :index, users_count: Accounts.count_users())
  end

  def create_user_invite(conn, _params) do
    redirect(conn, to: ~p"/admin/user_invites/10")
  end

  def show_user_invite(conn, _params) do
    render(conn, :show_user_invite)
  end
end
