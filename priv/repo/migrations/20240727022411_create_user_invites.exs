defmodule Iris.Repo.Migrations.CreateUserInvites do
  use Ecto.Migration

  def change do
    create table(:user_invites) do
      add :external_id, :uuid, null: false
      add :used, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_invites, [:external_id])
  end
end
