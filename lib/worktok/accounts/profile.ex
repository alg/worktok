defmodule Worktok.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    embeds_one :billing_address, Worktok.Accounts.BillingAddress
    belongs_to :user, Worktok.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [])
    |> cast_embed(:billing_address)
  end
end
