defmodule Iris.Accounts.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :used, :boolean, default: false
    field :valid_until, :utc_datetime
    field :external_id, Ecto.UUID, autogenerate: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:valid_until, :used])
    |> validate_required([:valid_until, :used])
  end
end
