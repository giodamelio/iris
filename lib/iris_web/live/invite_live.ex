defmodule IrisWeb.InviteLive do
  use IrisWeb, :live_view

  def render(assigns) do
    ~H"""
    Create User
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
