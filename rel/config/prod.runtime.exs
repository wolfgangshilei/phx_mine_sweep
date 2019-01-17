use Mix.Config

config :mine_sweep, MineSweepWeb.Endpoint,
  http: [:inet6,
         port: {:system, "PORT"}],
  url: [host: "mine-sweep-1008.herokuapp.com", port: {:system, "PORT"}],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :mine_sweep, MineSweep.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
