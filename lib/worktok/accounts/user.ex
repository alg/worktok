defmodule Worktok.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Worktok.Accounts.Credential

  schema "users" do
    field :name, :string

    has_one :credential, Credential, on_delete: :delete_all
    has_many :clients, Worktok.Registry.Client, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end

end
