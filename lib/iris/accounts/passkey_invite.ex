defmodule Iris.Accounts.PasskeyInvite do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "passkey_invites" do
    field :external_id, Ecto.UUID
    field :used, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passkey_invite, attrs) do
    passkey_invite
    |> cast(attrs, [:external_id, :used])
    |> validate_required([:external_id, :used])
    |> unique_constraint([:external_id])
  end
end
