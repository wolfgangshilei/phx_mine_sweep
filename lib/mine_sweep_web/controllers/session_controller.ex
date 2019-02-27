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

  @max_records_num 50
  @default_records_num 5

  @doc false
  def records_by_username(conn, %{"username" => username} = params) do
    {n, order_by} = check_records_params params

    r =
      case order_by do
        "latest" ->
          Users.list_latest_records_by_username(username, n)

        _ ->
          Users.list_best_records_by_username(username, n)
      end
    r = r |> Enum.group_by(&Map.get(&1, :level))
    r |> inspect |> Logger.debug
    json(conn, %{result: :ok, data: r})
  end

  @doc false
  def all_time_best_records(conn, params) do
    {n, _} = check_records_params params

    result =
      Users.list_all_time_best_records(n)
      |> Enum.group_by(&Map.get(&1, :level))
    result |> inspect |> Logger.debug
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

  defp check_records_params(params) do
    n =
      case Map.get(params, "n", "") |> Integer.parse do
        {n, _} when n <= @max_records_num ->
          n
        :error ->
          @default_records_num
      end
    order_by = Map.get(params, "order-by", "best")

    {n, order_by}
  end

end
