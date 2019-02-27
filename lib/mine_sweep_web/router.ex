defmodule MineSweepWeb.Router do
  use MineSweepWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/", MineSweepWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  pipeline :api do
    plug Plug.RequestId
    plug :accepts, ["json"]
  end


  scope "/api/v1/auth", MineSweepWeb do
    pipe_through :api

    post "/login", AuthController, :login
    post "/signup", AuthController, :signup
  end

  scope "/api/v1/session", MineSweepWeb do
    pipe_through :api

    get "/", SessionController, :session
    post "/record", SessionController, :create_record
    get "/records/user/:username", SessionController, :records_by_username
    get "/records/all-time-best", SessionController, :all_time_best_records
  end
end
