defmodule IrisWeb.InviteUserLive do
  use IrisWeb, :live_view

  alias Iris.Accounts
  alias Iris.Accounts.User

  # Show error for invalid id or used invite
  @impl true
  def render(assigns) when assigns.invite == nil or assigns.invite.used == true do
    ~H"""
    <.section title="Invalid User Invite" subtitle="Please double check URL or request new invite">
      <.link navigate={~p"/"}>Go Home</.link>
    </.section>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={IrisWeb.UserLive.FormComponent}
      id={:new}
      title="Create User"
      action={:new}
      user={%User{}}
    />
    """
  end

  @impl true
  def mount(%{"id" => external_id} = _params, _session, socket) do
    invite = Accounts.get_user_invite_by_external_id(external_id)

    socket =
      socket
      |> assign(:invite, invite)

    {:ok, socket}
  end

  @impl true
  def handle_info({IrisWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    IO.inspect("User created")
    IO.inspect(user)
    {:noreply, socket}
  end
end
