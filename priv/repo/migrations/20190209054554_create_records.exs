defmodule MineSweep.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :record, :integer
      add :level, :string
      add :credential_id, references(:credentials, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:records, [:credential_id])
    create index(:records, [:record])
  end
end
