defmodule Iris.Accounts.PasskeyInvite do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Iris.Accounts

  schema "passkey_invites" do
    field :external_id, Ecto.UUID
    field :used, :boolean, default: false

    belongs_to :user, Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passkey_invite, attrs) do
    passkey_invite
    |> cast(attrs, [:external_id, :used, :user_id])
    |> validate_required([:external_id, :used, :user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:external_id])
  end
end
