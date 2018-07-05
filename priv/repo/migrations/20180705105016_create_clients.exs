defmodule Worktok.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string
      add :email, :string
      add :prefix, :string
      add :active, :boolean, default: false, null: false
      add :rate, :decimal
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:clients, [:prefix])
    create index(:clients, [:user_id])
  end
end
