defmodule MineSweepWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> fetch_session
    |> configure_session(drop: true)
    |> put_status(403)
    |> json(%{result: :error})
  end

  def call(conn, {:error, :wrong_params}) do
    conn
    |> put_status(400)
    |> json(%{result: :error})
  end
end
