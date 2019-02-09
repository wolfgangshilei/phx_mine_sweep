defmodule MineSweep.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias MineSweep.Repo

  alias MineSweep.Users.Credential

  alias Bcrypt

  @doc """
  Check if user exists with given username and password.

  Returns {:ok, %Credential{}} if login successfully, otherwise returns
  {:error, :unauthorized}
  """
  def authorize_by_username_and_password(username, password) do
    q =
      from c in Credential,
      where: c.username == ^username

    case Repo.one(q) do
      %Credential{password: stored_hash} = c ->
        case Bcrypt.verify_pass password, stored_hash do
          true ->
            {:ok, c}
          false ->
            {:error, :unauthorized}
        end
      _ ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(%{password: password} = attrs \\ %{}) do
    hashed_store =
      Bcrypt.hash_pwd_salt password
    hashed_attrs = Map.replace! attrs, :password, hashed_store

    %Credential{}
    |> Credential.changeset(hashed_attrs)
    |> Repo.insert()
  end

  alias MineSweep.Users.Record

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_best_records_by_username("Username", 3)
      [%Record{}, ...]

  """
  def list_best_records_by_username(username, n) do
    sq = from r in Record,
      inner_join: c in assoc(r, :credential), on: c.username == ^username,
      select: %{level: r.level,
                inserted_at: r.inserted_at,
                record: r.record,
                row_number: over(row_number(), :levels)},
      windows: [levels: [partition_by: r.level, order_by: [asc: r.record]]]
    res = from r in subquery(sq),
      where: r.row_number <= ^n
    Repo.all(res)
  end

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_latest_records_by_username("Username", 3)
      [%Record{}, ...]

  """
  def list_latest_records_by_username(username, n) do
    sq = from r in Record,
      inner_join: c in assoc(r, :credential), on: c.username == ^username,
      select: %{level: r.level,
                inserted_at: r.inserted_at,
                record: r.record,
                row_number: over(row_number(), :levels)},
      windows: [levels: [partition_by: r.level, order_by: [desc: r.inserted_at]]]
    res = from r in subquery(sq),
      where: r.row_number <= ^n
    Repo.all(res)
  end

  @doc """
  Creates a record.

  ## Examples

      iex> create_record(%{field: value})
      {:ok, %Record{}}

      iex> create_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_record(%Credential{} = c, attrs \\ %{}) do
    c
    |> Ecto.build_assoc(:records, %{})
    |> Record.changeset(attrs)
    |> Repo.insert()
  end
end
