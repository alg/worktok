defmodule Worktok.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias Worktok.Repo

  alias Worktok.Accounts
  alias Worktok.Accounts.User
  alias Worktok.Billing.Invoice
  alias Worktok.Registry.{Client,Project}

  @doc """
  Returns the list of user invoices.
  """
  def list_user_invoices(%User{} = user) do
    Invoice
    |> Accounts.user_scope_query(user)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single invoice.
  """
  def get_user_invoice!(%User{} = user, id) do
    from(i in Invoice, where: i.id == ^id)
    |> Accounts.user_scope_query(user)
    |> Repo.one!()
    |> Repo.preload(:user)
  end

  @doc """
  Creates a invoice.
  """
  def create_invoice(%User{} = user, %Project{} = project, attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> put_user(user)
    |> put_project(project)
    |> put_client(project.client)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.
  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Invoice.
  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.
  """
  def change_invoice(%Invoice{} = invoice) do
    Invoice.changeset(invoice, %{})
  end


  alias Worktok.Billing.Work

  @doc """
  Returns the list of works.
  """
  def list_user_works(%User{} = user) do
    Work
    |> Accounts.user_scope_query(user)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Returns user recent work.
  """
  def recent_work(%User{} = user) do
    week_ago =
      Date.utc_today()
      |> Date.add(-7)

    Work
    |> Accounts.user_scope_query(user)
    |> where([w], w.worked_on > ^week_ago)
    |> where([w], is_nil(w.invoice_id))
    |> order_by(desc: :worked_on)
    |> Repo.all
    |> Repo.preload(project: [:client])
  end

  @doc """
  Gets a single work.
  """
  def get_user_work!(%User{} = user, id) do
    from(w in Work, where: w.id == ^id)
    |> Accounts.user_scope_query(user)
    |> Repo.one!()
    |> Repo.preload(:user)
  end

  @doc """
  Creates a work.
  """
  def create_work(%User{} = user, attrs \\ %{}) do
    %Work{}
    |> Work.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a work.
  """
  def update_work(%Work{} = work, attrs) do
    work
    |> Work.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Work.
  """
  def delete_work(%Work{} = work) do
    Repo.delete(work)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work changes.
  """
  def change_work(%Work{} = work) do
    Work.changeset(work, %{})
  end

  defp put_user(changeset, %User{} = user), do: Ecto.Changeset.put_assoc(changeset, :user, user)
  defp put_client(changeset, %Client{} = client), do: Ecto.Changeset.put_assoc(changeset, :client, client)
  defp put_project(changeset, %Project{} = project), do: Ecto.Changeset.put_assoc(changeset, :project, project)

end
