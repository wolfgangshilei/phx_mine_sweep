defmodule MineSweepWeb.SessionController do
  use MineSweepWeb, :controller
  alias MineSweep.{Users, Users.Credential, Users.Record}

  require Logger

  action_fallback MineSweepWeb.FallbackController

  plug :authorize when action in [:session,
                                  :create_record]

  @doc false
  def session(conn, _) do
    user = conn |> fetch_session |> get_session(:user)
    json(conn, %{result: :ok,
                 data:   user})
  end

  @doc false
  def create_record(conn, %{"record" => ms, "level" => level}) do
    user =
      conn
      |> fetch_session
      |> get_session(:user)

    case Users.create_record(
          struct(Credential, user),
          %{record: ms, level: level}
        ) do
      {:ok, %Record{} = r} ->
        json(conn, %{result: :ok,
                     data:   Map.take(r, [:inserted_at, :level, :record])})

      {:error, %Ecto.Changeset{errors: e}} ->
        e_str = inspect e
        Logger.error(e_str)
        json(conn, %{result: :error, reason: e_str})
    end
  end
  def create_record(_, _), do: {:error, :wrong_params}

  @doc false
  def list_records(conn, params) do
    ## TODO: ad-hoc mapping from kebab to snake case for field order-by.
    ##       Should use a plug (there are 3rd party libraries)
    ##       as a more robust solution
    params = Map.put(params, "order_by", Map.get(params, "order-by", nil))

    result =
      Users.list_records(params)
      |> Enum.group_by(&Map.get(&1, :level))
    json(conn, %{result: :ok, data: result})
  end

  def authorize(conn, _) do
    case conn
    |> fetch_session
    |> get_session(:user) do
      %{id: _, username: _} ->
        conn
      _ ->
        conn
        |> put_status(403)
        |> json(%{result: :error})
        |> halt
    end
  end
end
