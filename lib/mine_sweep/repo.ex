defmodule MineSweep.Repo do
  use Ecto.Repo,
    otp_app: :mine_sweep,
    adapter: Ecto.Adapters.Postgres
end
