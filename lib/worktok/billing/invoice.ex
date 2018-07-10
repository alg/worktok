defmodule Worktok.Billing.Invoice do
  use Ecto.Schema
  import Ecto.Changeset


  schema "invoices" do
    field :forgiven, :boolean, default: false
    field :hours, :decimal
    field :paid_on, :date
    field :ref, :string
    field :total, :decimal

    belongs_to :user, Worktok.Accounts.User
    belongs_to :client, Worktok.Registry.Client
    belongs_to :project, Worktok.Registry.Project

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:ref, :total, :hours, :paid_on, :forgiven])
    |> validate_required([:ref, :total])
  end
end
