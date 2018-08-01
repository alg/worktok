defmodule Worktok.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias Worktok.Repo

  alias Worktok.Accounts
  alias Worktok.Accounts.User
  alias Worktok.Billing.Work
  alias Worktok.Billing.Invoice
  alias Worktok.Registry.{Client,Project}

  @last_work_copy_duration Timex.Duration.from_minutes(30)

  @doc """
  Returns the duration, during which the last entered work is used for work date copy.
  This is useful when you enter past work. This way you don't need to change the date over
  and over to the one in the past.
  """
  def last_work_copy_duration(), do: @last_work_copy_duration

  @doc """
  Returns the list of user invoices.
  """
  def list_user_invoices(%User{} = user) do
    Invoice
    |> Accounts.user_scope_query(user)
    |> order_by(desc: :paid_on, asc: :inserted_at)
    |> Repo.all
    |> Repo.preload([:user, :client, :project])
  end

  @doc """
  Returns the list of all pending invoices.
  """
  def list_pending_invoices(%User{} = user) do
    Invoice
    |> Accounts.user_scope_query(user)
    |> select([i], {i.id, i.ref, i.total})
    |> where([i], is_nil(i.paid_on))
    |> order_by(asc: :inserted_at)
    |> Repo.all
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
  def create_invoice(%Project{user: user} = project, attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> put_user(user)
    |> put_project(project)
    |> put_client(project.client)
    |> Repo.insert()
  end

  def create_invoice_from_unpaid_work(%Project{id: project_id, prefix: prefix} = project) do
    uninvoiced_project_work =
      from w in Work,
        where: w.project_id == ^project_id and is_nil(w.invoice_id)

    count =
      from w in uninvoiced_project_work,
        select: count(w.id)

    cond do
      Repo.one!(count) > 0 ->
        {hours, total} =
          (from w in uninvoiced_project_work,
            select: {sum(w.hours), sum(w.total)})
            |> Repo.one!

        today =
          Timex.format!(Timex.today(), "%Y%m%d", :strftime)

        {:ok, invoice = %Invoice{id: invoice_id}} =
          create_invoice(project, %{ref: prefix <> today, hours: hours, total: total})

        uninvoiced_project_work
          |> Repo.update_all(set: [invoice_id: invoice_id])

        {:ok, invoice}

      true ->
        {:error, :no_work}
    end
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

  def pay_invoice(%Invoice{paid_on: nil} = invoice) do
    update_invoice(invoice, %{paid_on: Timex.now()})
  end
  def pay_invoice(%Invoice{} = invoice), do: {:ok, invoice}

  def unpay_invoice(%Invoice{paid_on: nil} = invoice), do: {:ok, invoice}
  def unpay_invoice(%Invoice{} = invoice) do
    update_invoice(invoice, %{paid_on: nil})
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
  def recent_work(%User{} = user, since_date \\ Timex.beginning_of_month(Timex.today())) do
    Work
    |> Accounts.user_scope_query(user)
    |> where([w], w.worked_on >= ^since_date)
    |> where([w], is_nil(w.invoice_id))
    |> order_by(desc: :worked_on)
    |> Repo.all
    |> Repo.preload(project: [:client])
  end

  @doc """
  Returns summary of current (uninvoiced) work in the form:

  [ {project_id, project_name, total} ]
  """
  def current_work(%User{id: user_id}) do
    uninvoiced =
      from w in Work,
        join: p in Project, on: w.project_id == p.id,
        select: {p.id, p.name, sum(w.total)},
        where: w.user_id == ^user_id and is_nil(w.invoice_id),
        group_by: p.id,
        order_by: [p.name, p.id]

    Repo.all(uninvoiced)
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
          Timex.after?(last_work.inserted_at, Timex.subtract(Timex.now(), @last_work_copy_duration)) ->
            {work.project_id, work.worked_on}

          true ->
            {work.project_id, Timex.today()}
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
  def earnings(%User{id: user_id}, on \\ Timex.today()) do
    user_work =
      from w in Work,
        select: sum(w.total),
        where: w.user_id == ^user_id

    this_week =
      from w in user_work,
        where: w.worked_on >= ^Timex.beginning_of_week(on)

    this_month =
      from w in user_work,
        where: w.worked_on >= ^Timex.beginning_of_month(on)

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
