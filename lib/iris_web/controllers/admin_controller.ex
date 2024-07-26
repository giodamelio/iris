defmodule IrisWeb.AdminController do
  use IrisWeb, :controller

  alias Iris.Accounts
  alias Iris.Accounts.Invite

  def index(conn, _params) do
    render(conn, :index)
  end
end
