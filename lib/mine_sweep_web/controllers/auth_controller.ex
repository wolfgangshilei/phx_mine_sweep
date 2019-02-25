defmodule MineSweepWeb.AuthController do
  use MineSweepWeb, :controller
  alias MineSweep.{Users, Users.Credential}
  require Logger

  action_fallback MineSweepWeb.FallbackController

  def login(conn, params) do
    attrs =
      params
      |> Map.take(["username", "password"])
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    case Users.authenticate_username_and_password(attrs) do
      {:ok, %Credential{} = cred} ->
        conn
        |> fetch_session
        |> put_session(:user, Map.take(cred, [:id, :username]))
        |> configure_session(renew: true)
        |> json(%{result: :ok})

      {:error, %Ecto.Changeset{} = changeset} ->
        json(conn, %{result: :error, reason: changeset_to_errors(changeset)})

      {:error, :wrong_username_or_password} ->
        {:error, :unauthenticated}
    end
  end

  def signup(conn, params) do
    attrs =
      params
      |> Map.take(["username", "password"])
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    case Users.create_credential(attrs) do
      {:ok, %Credential{} = cred} ->
        conn
        |> fetch_session
        |> put_session(:user, Map.take(cred, [:id, :username]))
        |> json(%{result: :ok})

      {:error, %Ecto.Changeset{} = changeset} ->
        json(conn, %{result: :error, reason: changeset_to_errors(changeset)})
    end
  end

  defp changeset_to_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
