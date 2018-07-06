defmodule Worktok.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :active, :boolean, default: false, null: false
      add :name, :string
      add :prefix, :string
      add :rate, :decimal
      add :client_id, references(:clients, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:projects, [:prefix, :user_id])
    create index(:projects, [:user_id])
  end
end
