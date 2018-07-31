defmodule Worktok.Repo.Migrations.AddProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :billing_address, :map

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
