defmodule Worktok.Repo.Migrations.CreateWorks do
  use Ecto.Migration

  def change do
    create table(:works) do
      add :task, :string, null: false
      add :hours, :decimal
      add :total, :decimal, null: false
      add :worked_on, :date, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :project_id, references(:projects, on_delete: :nothing), null: false
      add :invoice_id, references(:invoices, on_delete: :nothing)

      timestamps()
    end

    create index(:works, [:user_id])
    create index(:works, [:project_id])
    create index(:works, [:invoice_id])
  end
end
