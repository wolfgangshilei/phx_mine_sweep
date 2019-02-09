defmodule MineSweep.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :username, :string
      add :password, :string

      timestamps()
    end

    create unique_index(:credentials, [:username])
  end
end
