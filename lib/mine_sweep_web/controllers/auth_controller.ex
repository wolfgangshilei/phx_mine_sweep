defmodule MineSweepWeb.AuthController do
  use MineSweepWeb, :controller
  alias MineSweep.{Users, Users.Credential}
  require Logger

  action_fallback MineSweepWeb.FallbackController

  def login(conn, %{"username" => username, "password" => password}) do
    case Users.authorize_by_username_and_password(username, password) do
      {:ok, %Credential{} = cred} ->
        conn
        |> fetch_session
        |> put_session(:user, Map.take(cred, [:id, :username]))
        |> configure_session(renew: true)
        |> json(%{result: :ok})
      _ ->
        {:error, :unauthorized}
    end
  end
  def login(_, _), do: {:error, :unauthorized}

  def signup(conn, %{"username" => username, "password" => password}) do
    case Users.create_credential(%{username: username, password: password}) do
      {:ok, %Credential{} = cred} ->
        conn
        |> fetch_session
        |> put_session(:user, Map.take(cred, [:id, :username]))
        |> json(%{result: :ok})
      {:error, %Ecto.Changeset{}} ->
        json(conn, %{result: :fail, reason: "Invalid username or password."})
    end
  end
  def signup(_, _), do: {:error, :wrong_params}
end
