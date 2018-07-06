defmodule Worktok.Registry.Project do
  use Ecto.Schema
  import Ecto.Changeset


  schema "projects" do
    field :active, :boolean, default: false
    field :name, :string
    field :prefix, :string
    field :rate, :decimal

    belongs_to :user, Worktok.Accounts.User
    belongs_to :client, Worktok.Registry.Client

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :prefix, :active, :rate, :client_id])
    |> validate_required([:name, :prefix, :active, :rate, :client_id])
    |> unique_constraint(:prefix, name: :projects_prefix_user_id_index)
  end
end
