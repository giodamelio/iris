defmodule IrisWeb.AdminController do
  use IrisWeb, :controller

  alias Iris.Accounts

  def index(conn, _params) do
    render(conn, :index, users_count: Accounts.count_users())
  end
end
