defmodule Worktok.Billing.Work do
  use Ecto.Schema
  import Ecto.Changeset


  schema "works" do
    field :hours, :decimal
    field :task, :string
    field :total, :decimal
    field :worked_on, :date

    belongs_to :user, Worktok.Accounts.User
    belongs_to :project, Worktok.Registry.Project
    belongs_to :invoice, Worktok.Billing.Invoice

    timestamps()
  end

  @doc false
  def changeset(work, attrs) do
    work
    |> cast(attrs, [:task, :hours, :total, :worked_on, :project_id])
    |> validate_required([:task, :total, :worked_on, :project_id])
  end
end
