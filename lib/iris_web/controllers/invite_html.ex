defmodule IrisWeb.InviteHTML do
  use IrisWeb, :html

  embed_templates "invite_html/*"

  @doc """
  Renders a invite form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def invite_form(assigns)
end
