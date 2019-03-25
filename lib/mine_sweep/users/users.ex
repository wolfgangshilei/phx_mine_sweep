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
  If the given username and password are invalid, returns {:error, %Ecto.Changeset{}}.

  Returns {:ok, %Credential{}} if username and password are correctly checked against stored credential,
  otherwise returns {:error, :unauthenticated}
  """
  def authenticate_username_and_password(attrs) do
    case Credential.query_params_check(%Credential{}, attrs)
      do
      %Ecto.Changeset{valid?: true, changes: %{password: password, username: username}} ->
        q = from c in Credential, where: c.username == ^username

        with cred = %Credential{password: stored_hash} <- Repo.one(q),
             true <- Bcrypt.verify_pass(password, stored_hash) do
                {:ok, cred}
        else
          _ ->
            {:error, :wrong_username_or_password}
        end

      %Ecto.Changeset{valid?: false} = change ->
        {:error, change}
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
  def create_credential(attrs) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  alias MineSweep.Users.Record

  @default_records_num 5

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_records("best", "Username", 3)
      [%Record{}, ...]

  """
  def list_records(params) do
    import Ecto.Changeset

    query_params =
    {%{}, %{n: :integer, username: :string, order_by: :string}}
    |> cast(params, [:n, :username, :order_by])

    do_list_records(
      get_change(query_params, :order_by),
      get_change(query_params, :username),
      get_change(query_params, :n, @default_records_num)
    )
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

  defp do_list_records(order, username, n) do
    all_users =  if username, do: dynamic([r, c], c.username == ^username), else: true

    basic_query =
      from r in Record,
      inner_join: c in assoc(r, :credential), on: ^all_users,
      select: %{level: r.level,
                inserted_at: r.inserted_at,
                record: r.record,
                username: c.username,
                row_number: over(row_number(), :levels)}

    query = case order do
              "latest" ->
                basic_query |> windows([r, c], [levels: [partition_by: r.level, order_by: [desc: r.inserted_at]]])
              _ ->
                ## order by best time by default
                basic_query |> windows([r, c], [levels: [partition_by: r.level, order_by: [asc: r.record]]])
            end

    Repo.all(from r in subquery(query), where: r.row_number <= ^n)
  end
end
