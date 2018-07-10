defmodule Worktok.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :ref, :string, null: false
      add :total, :decimal, null: false
      add :hours, :decimal
      add :paid_on, :date
      add :forgiven, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :client_id, references(:clients, on_delete: :nothing), null: false
      add :project_id, references(:projects, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:invoices, [:user_id, :ref])
    create index(:invoices, [:user_id])
    create index(:invoices, [:client_id])
    create index(:invoices, [:project_id])
  end
end
