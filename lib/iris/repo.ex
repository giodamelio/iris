defmodule Iris.Repo do
  use Ecto.Repo,
    otp_app: :iris,
    adapter: Ecto.Adapters.SQLite3
end
