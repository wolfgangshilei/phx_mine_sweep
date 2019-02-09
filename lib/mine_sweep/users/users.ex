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
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential!(123)
      %Credential{}

      iex> get_credential!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credential!(id), do: Repo.get!(Credential, id)

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

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential)
      %Ecto.Changeset{source: %Credential{}}

  """
  def change_credential(%Credential{} = credential) do
    Credential.changeset(credential, %{})
  end
end
