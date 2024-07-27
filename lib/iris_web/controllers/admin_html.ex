defmodule IrisWeb.AdminHTML do
  use IrisWeb, :html

  alias Iris.Accounts.UserInvite

  embed_templates "admin_html/*"

  def generate_invite_url(%UserInvite{external_id: external_id}) do
    url(~p"/invite/user/#{external_id}")
  end
end
