defmodule Alternis.Repo do
  use Ecto.Repo,
    otp_app: :alternis,
    adapter: Ecto.Adapters.Postgres
end
