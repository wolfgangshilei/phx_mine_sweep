defmodule DevOnly do
  defmacro dev_only(body) do
    quote do
      if Mix.env() == :dev, do: unquote(body)
    end
  end
end

defmodule MineSweepWeb.Router do
  use MineSweepWeb, :router
  import DevOnly

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/", MineSweepWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  pipeline :api do
    dev_only(plug CORSPlug, origin: ["http://localhost:3449", "http://127.0.0.1:3449"])
    plug Plug.RequestId
    plug :accepts, ["json"]
  end

  scope "/api/v1", MineSweepWeb do
    pipe_through :api

    dev_only(options "/auth/login", AuthController, :options)
    dev_only(options "/auth/signup", AuthController, :options)
    dev_only(options "/auth/session", AuthController, :options)
    post "/auth/login", AuthController, :login
    post "/auth/signup", AuthController, :signup
    get "/auth/session", AuthController, :session
  end
end
