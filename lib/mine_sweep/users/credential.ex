defmodule MineSweep.Users.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :password, :string
    field :username, :string

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
