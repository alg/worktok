defmodule Worktok.TestHelpers do

  alias Worktok.Accounts
  alias Worktok.Registry

  def insert_user(attrs \\ %{}) do
    i = System.unique_integer([:positive])

    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "John Doe",
        credential: %{
          email: "john-#{i}@doe.com",
          password: "supersecret"
        }
      })
      |> Accounts.create_user()

    user
  end

  def insert_client(%Accounts.User{} = user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{
      active: true,
      email: "client@email.com",
      name: "Some Client",
      prefix: "SC",
      rate: "100.25"
    })

    {:ok, client} = Registry.create_client(user, attrs)

    client
  end

end
