defmodule Iris.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :valid_until, :utc_datetime
      add :used, :boolean, default: false, null: false
      add :external_id, :uuid, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
