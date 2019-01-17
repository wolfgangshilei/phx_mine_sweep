defmodule MineSweepWeb.Router do
  use MineSweepWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MineSweepWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", MineSweepWeb do
    pipe_through :api
  end
end
