defmodule Iris.Accounts.UserInvite do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_invites" do
    field :external_id, Ecto.UUID
    field :used, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_invite, attrs) do
    user_invite
    |> cast(attrs, [:external_id, :used])
    |> validate_required([:external_id, :used])
    |> unique_constraint([:external_id])
  end
end
