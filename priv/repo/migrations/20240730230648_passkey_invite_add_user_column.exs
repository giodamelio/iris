defmodule Iris.Repo.Migrations.PasskeyInviteAddUserColumn do
  use Ecto.Migration

  def change do
    alter table(:passkey_invites) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
