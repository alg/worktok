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
      Timex.today()
      |> Timex.beginning_of_month()

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

  @doc """
  Prepares changeset for the new work.
  """
  def new_work(%User{} = _current_user, %{"work" => work_params}) do
    Work.changeset(%Work{}, work_params)
  end
  def new_work(%User{} = user, _) do
    last_work =
      Work
      |> Accounts.user_scope_query(user)
      |> order_by(desc: :id)
      |> select([:id, :project_id, :worked_on, :inserted_at])
      |> limit(1)
      |> Repo.one

    {project_id, worked_on} = case last_work do
      nil ->
        {nil, Date.utc_today()}

      work ->
        cond do
          Timex.after?(last_work.inserted_at, Timex.subtract(Timex.now(), Timex.Duration.from_minutes(30))) ->
            {work.project_id, work.worked_on}

          true ->
            {work.project_id, Date.utc_today()}
        end
    end

    Work.changeset(%Work{}, %{worked_on: worked_on, project_id: project_id})
  end

  defp put_user(changeset, %User{} = user), do: Ecto.Changeset.put_assoc(changeset, :user, user)
  defp put_client(changeset, %Client{} = client), do: Ecto.Changeset.put_assoc(changeset, :client, client)
  defp put_project(changeset, %Project{} = project), do: Ecto.Changeset.put_assoc(changeset, :project, project)

  @doc """
  Looks up user earnigns in the given periods.
  """
  def earnings(%User{id: user_id}) do
    user_work =
      from w in Work,
        select: sum(w.total),
        where: w.user_id == ^user_id

    this_week =
      from w in user_work,
        where: w.worked_on >= ^Timex.beginning_of_week(Timex.today())

    this_month =
      from w in user_work,
        where: w.worked_on >= ^Timex.beginning_of_month(Timex.today())

    unpaid =
      from w in user_work,
        left_join: i in Invoice, on: w.invoice_id == i.id,
        where: is_nil(w.invoice_id) or
               (is_nil(i.paid_on) and i.forgiven == false)

    [ this_week: Repo.one!(this_week),
      this_month: Repo.one!(this_month),
      unpaid: Repo.one!(unpaid)
    ]
  end
end
