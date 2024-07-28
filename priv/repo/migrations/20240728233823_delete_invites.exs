defmodule Iris.Repo.Migrations.DeleteInvites do
  use Ecto.Migration

  def change do
    drop table("invites")
  end
end
