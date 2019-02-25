defmodule MineSweep.Users.Credential do
  use Ecto.Schema

  import Ecto.Changeset
  alias MineSweep.Users.Record
  alias Bcrypt

  schema "credentials" do
    field :password, :string
    field :username, :string
    has_many :records, Record

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, max: 50)
    |> validate_length(:password, min: 6, max: 50)
    |> validate_format(
      :username, ~r"^[a-zA-Z0-9@#_.]*$",
      message: "should only contain letters, digits and characters in @.#_")
    |> validate_format(
      :password, ~r"^[a-zA-Z0-9@#_!$%]*$",
      message: "should only contain letters, digits and characters in @.#_!$%")
    |> unique_constraint(:username)
    |> update_change(:password, &Bcrypt.hash_pwd_salt/1)
  end

  @doc false
  def query_params_check(credential, attrs) do
    credential
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
  end
end
