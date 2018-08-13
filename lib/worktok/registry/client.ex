defmodule Worktok.Registry.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :active, :boolean, default: false
    field :email, :string
    field :name, :string
    field :prefix, :string
    field :rate, :decimal

    belongs_to :user, Worktok.Accounts.User
    has_many :projects, Worktok.Registry.Project

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :email, :prefix, :active, :rate])
    |> validate_required([:name, :email, :prefix, :active, :rate])
    |> unique_constraint(:prefix, name: :clients_user_id_prefix_index)
  end

  def delete_changeset(client) do
    client
    |> change
    |> no_assoc_constraint(:projects, message: "are still associated with this client.")
  end
end
