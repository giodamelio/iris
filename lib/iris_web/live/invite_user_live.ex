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
    <.section title="Create User">
      <.simple_form for={@form} id="user-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:full_name]} type="text" label="Full name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <:actions>
          <.button phx-disable-with="Saving..." class="button is-primary">Save User</.button>
        </:actions>
      </.simple_form>
    </.section>
    """
  end

  @impl true
  def mount(%{"id" => external_id} = _params, _session, socket) do
    invite = Accounts.get_user_invite_by_external_id(external_id)

    socket =
      socket
      |> assign(:invite, invite)
      |> assign(:form, to_form(Accounts.change_user(%User{})))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      %User{}
      |> Accounts.change_user(user_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.create_user_from_invite(user_params, socket.assigns.invite) do
      {:ok, _user} ->
        {:noreply, redirect(socket, to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
