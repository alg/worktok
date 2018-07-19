defmodule Worktok.TestHelpers do

  alias Worktok.Accounts
  alias Worktok.Registry
  alias Worktok.Billing

  def user_fixture(attrs \\ %{}) do
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

  def client_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{
      active: true,
      email: "client@email.com",
      name: "Some Client",
      prefix: "SC#{:rand.uniform(100000)}",
      rate: "100.25"
    })

    {:ok, client} = Registry.create_client(user, attrs)

    client
  end

  def project_fixture(%Registry.Client{} = client, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{
      active: true,
      name: "Some Project",
      prefix: "SP#{:rand.uniform(100000)}",
      rate: "50.25",
      client_id: client.id
    })

    {:ok, project} = Registry.create_project(client.user, attrs)
    project |> Worktok.Repo.preload(:client)
  end

  def invoice_fixture(%Accounts.User{} = user, %Registry.Project{} = project, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{
      ref: "someref",
      total: "120.50",
    })

    {:ok, invoice} = Billing.create_invoice(user, project, attrs)
    invoice
  end


  def work_fixture() do
    work_fixture(%{})
  end
  def work_fixture(attrs) do
    user = user_fixture()
    work_fixture(user, attrs)
  end

  def work_fixture(%Accounts.User{} = user, attrs) do
    attrs = Enum.into(attrs, %{
      task: "Sample task",
      hours: "2",
      total: "150",
      worked_on: "2018-10-24"
    })

    attrs = case Map.get(attrs, :project_id) do
      nil ->
        client = client_fixture(user)
        project = project_fixture(client)

        Enum.into(attrs, %{project_id: project.id})

      _ -> attrs
    end

    {:ok, work} = Billing.create_work(user, attrs)
    work
  end


end
