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

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :email, :prefix, :active, :rate])
    |> validate_required([:name, :email, :prefix, :active, :rate])
    |> unique_constraint(:prefix)
  end
end
