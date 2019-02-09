defmodule MineSweep.Users.Record do
  use Ecto.Schema
  import Ecto.Changeset
  alias MineSweep.Users.Credential

  schema "records" do
    field :level, :string
    field :record, :integer
    belongs_to :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:record, :level])
    |> validate_required([:record, :level])
    |> validate_number(:record, greater_than: 0)
    |> validate_inclusion(:level, ["easy", "hard", "medium"])
  end
end
