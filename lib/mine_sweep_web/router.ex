defmodule MineSweepWeb.Router do
  use MineSweepWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MineSweepWeb do
    pipe_through :api
  end
end
