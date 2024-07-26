defmodule IrisWeb.UserLive.Index do
  use IrisWeb, :live_view

  alias Iris.Accounts
  alias Iris.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:users, Accounts.list_users())
      |> assign(:users_count, Accounts.count_users())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({IrisWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    socket =
      socket
      |> stream_insert(:users, user)
      |> assign(:users_count, Accounts.count_users())

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    socket =
      socket
      |> stream_delete(:users, user)
      |> assign(:users_count, Accounts.count_users())

    {:noreply, socket}
  end
end
