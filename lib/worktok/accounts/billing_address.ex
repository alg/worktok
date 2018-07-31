defmodule Worktok.Accounts.BillingAddress do
  use Ecto.Schema
  import Ecto.Changeset


  embedded_schema do
    field :name, :string
    field :street, :string
    field :zip, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :email, :string
    field :phone, :string
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:name, :street, :zip, :city, :state, :country, :email, :phone])
  end
end
