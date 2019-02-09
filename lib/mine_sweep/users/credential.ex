defmodule MineSweep.Users.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias MineSweep.Users.Record

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
    |> unique_constraint(:username)
  end
end
