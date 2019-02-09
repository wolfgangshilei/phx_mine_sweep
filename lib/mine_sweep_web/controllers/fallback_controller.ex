defmodule MineSweepWeb.FallbackController do
  use Phoenix.Controller
  @json_error %{result: :error}

  def call(conn, {:error, :unauthorized}) do
    conn
    |> fetch_session
    |> configure_session(drop: true)
    |> put_status(403)
    |> json(@json_error)
  end

  def call(conn, {:error, :wrong_params}) do
    conn
    |> put_status(400)
    |> json(@json_error)
  end

  def call(conn, {:error, :unknown}) do
    conn
    |> put_status(500)
    |> json(@json_error)
  end
end
