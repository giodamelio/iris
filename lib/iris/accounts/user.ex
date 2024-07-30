defmodule Iris.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Iris.Accounts

  schema "users" do
    field :email, :string
    field :full_name, :string

    has_many :passkey_invites, Accounts.PasskeyInvite

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :email])
    |> validate_required([:full_name, :email])
  end
end
