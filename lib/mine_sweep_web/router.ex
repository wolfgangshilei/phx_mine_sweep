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


  scope "/api/v1/auth", MineSweepWeb do
    pipe_through :api

    dev_only(options "/login", AuthController, :options)
    dev_only(options "/signup", AuthController, :options)
    post "/login", AuthController, :login
    post "/signup", AuthController, :signup
  end

  scope "/api/v1/session", MineSweepWeb do
    pipe_through :api

    dev_only(options "/", SessionController, :options)
    dev_only(options "/record", SessionController, :options)
    dev_only(options "/records/user/:username", SessionController, :options)
    get "/", SessionController, :session
    post "/record", SessionController, :create_record
    get "/records/user/:username", SessionController, :records_by_username
  end
end
