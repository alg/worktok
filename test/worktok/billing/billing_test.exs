defmodule Worktok.BillingTest do
  use Worktok.DataCase

  alias Worktok.Billing
  alias Worktok.Billing.Work
  alias Worktok.Billing.Invoice
  alias Worktok.Registry.Project

  defp create_invoice(attrs \\ %{}) do
    user = user_fixture()
    client = client_fixture(user)
    project = project_fixture(client)
    invoice = invoice_fixture(project, attrs)

    invoice
  end

  describe "invoices" do
    @valid_attrs %{
      forgiven: true,
      hours: "120.5",
      paid_on: ~D[2010-04-17],
      ref: "some ref",
      total: "120.5"
    }
    @update_attrs %{
      forgiven: false,
      hours: "456.7",
      paid_on: ~D[2011-05-18],
      ref: "some updated ref",
      total: "456.7"
    }
    @invalid_attrs %{forgiven: nil, hours: nil, paid_on: nil, ref: nil, total: nil}

    test "list_invoices/0 returns all invoices" do
      %Invoice{id: id, user: owner} = create_invoice()
      assert [%Invoice{id: ^id}] = Billing.list_user_invoices(owner)
    end

    test "get_invoice!/1 returns the invoice with given id" do
      %Invoice{id: id, user: owner} = create_invoice()
      assert %Invoice{id: ^id} = Billing.get_user_invoice!(owner, id)
    end

    test "create_invoice/1 with valid data creates a invoice" do
      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client) |> Worktok.Repo.preload(:client)

      assert {:ok, %Invoice{} = invoice} = Billing.create_invoice(project, @valid_attrs)
      assert invoice.forgiven == true
      assert invoice.hours == Decimal.new("120.5")
      assert invoice.paid_on == ~D[2010-04-17]
      assert invoice.ref == "some ref"
      assert invoice.total == Decimal.new("120.5")
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client) |> Worktok.Repo.preload(:client)

      assert {:error, %Ecto.Changeset{}} = Billing.create_invoice(project, @invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = create_invoice()
      assert {:ok, invoice} = Billing.update_invoice(invoice, @update_attrs)
      assert %Invoice{} = invoice
      assert invoice.forgiven == false
      assert invoice.hours == Decimal.new("456.7")
      assert invoice.paid_on == ~D[2011-05-18]
      assert invoice.ref == "some updated ref"
      assert invoice.total == Decimal.new("456.7")
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = create_invoice()
      assert {:error, %Ecto.Changeset{}} = Billing.update_invoice(invoice, @invalid_attrs)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = create_invoice()
      assert {:ok, %Invoice{}} = Billing.delete_invoice(invoice)

      assert_raise Ecto.NoResultsError, fn ->
        Billing.get_user_invoice!(invoice.user, invoice.id)
      end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = create_invoice()
      assert %Ecto.Changeset{} = Billing.change_invoice(invoice)
    end

    test "pay_invoice/1 marks invoice as paid" do
      invoice = create_invoice()
      {:ok, inv} = Billing.pay_invoice(invoice)
      assert Invoice.paid?(inv)
    end

    test "pay_invoice/1 doesn't mark already paid invoice" do
      yesterday = Timex.subtract(Timex.today(), Timex.Duration.from_days(1))
      invoice = create_invoice(%{paid_on: yesterday})
      assert {:ok, %Invoice{paid_on: ^yesterday}} = Billing.pay_invoice(invoice)
    end

    test "unpay_invoice/1 unpays paid invoice" do
      yesterday = Timex.subtract(Timex.today(), Timex.Duration.from_days(1))
      invoice = create_invoice(%{paid_on: yesterday})
      assert {:ok, %Invoice{paid_on: nil}} = Billing.unpay_invoice(invoice)
    end

    test "unpay_invoice/1 does nothing for unpaid invoice" do
      invoice = create_invoice(%{paid_on: nil})
      assert {:ok, %Invoice{paid_on: nil}} = Billing.unpay_invoice(invoice)
    end
  end

  describe "works" do
    @valid_attrs %{hours: "120.5", task: "some task", total: "120.5", worked_on: ~D[2010-04-17]}
    @update_attrs %{
      hours: "456.7",
      task: "some updated task",
      total: "456.7",
      worked_on: ~D[2011-05-18]
    }
    @invalid_attrs %{hours: nil, task: nil, total: nil, worked_on: nil}

    test "new_work/2 with params" do
      user = user_fixture()
      work_params = %{"hours" => "100", "total" => "7500", "task" => "Design"}
      hours = Decimal.new(100)
      total = Decimal.new(7500)

      assert %Ecto.Changeset{changes: %{hours: ^hours, total: ^total, task: "Design"}} =
               Billing.new_work(user, %{"work" => work_params})
    end

    test "new_work/2 without params and last work" do
      user = user_fixture()
      today = Date.utc_today()
      assert %Ecto.Changeset{changes: %{worked_on: ^today}} = Billing.new_work(user, nil)
    end

    test "new_work/2 with last work within threshold period" do
      %Work{user: user, project_id: project_id, worked_on: worked_on} = work_fixture()

      assert %Ecto.Changeset{changes: %{project_id: ^project_id, worked_on: ^worked_on}} =
               Billing.new_work(user, nil)
    end

    test "new_work/2 with last work past threshold duration (Billing.last_work_copy_duration) should ignore the time of work" do
      user = user_fixture()
      client = client_fixture(user)
      %Project{id: project_id} = project_fixture(client)

      over_duration =
        Timex.Duration.add(Billing.last_work_copy_duration(), Timex.Duration.from_minutes(1))

      {:ok, _work} =
        %Work{}
        |> Work.changeset(%{
          task: "Yesterday",
          hours: "2",
          total: "150",
          worked_on: "2018-10-24",
          project_id: project_id
        })
        |> Ecto.Changeset.put_assoc(:user, user)
        |> put_change(:inserted_at, Timex.subtract(Timex.now(), over_duration))
        |> Repo.insert()

      today = Timex.today()

      assert %Ecto.Changeset{changes: %{project_id: ^project_id, worked_on: ^today}} =
               Billing.new_work(user, nil)
    end

    test "list_user_works/1 returns all works" do
      %Work{id: id, user: owner} = work_fixture()
      assert [%Work{id: ^id}] = Billing.list_user_works(owner)
    end

    test "recent_work/1 returns recent user work" do
      today = Timex.today()

      bom = Timex.beginning_of_month(today)
      last_month = Timex.subtract(bom, Timex.Duration.from_days(1))
      this_month = Timex.add(bom, Timex.Duration.from_days(1))

      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client)

      work_bom =
        work_fixture(user, %{task: "task-bom", project_id: project.id, worked_on: strdate(bom)})

      work_last_month =
        work_fixture(user, %{
          task: "task-lm",
          project_id: project.id,
          worked_on: strdate(last_month)
        })

      work_this_month =
        work_fixture(user, %{
          task: "task-tm",
          project_id: project.id,
          worked_on: strdate(this_month)
        })

      user_2 = user_fixture()
      client_2 = client_fixture(user, prefix: "C2")
      project_2 = project_fixture(client_2, prefix: "P2")
      work_fixture(user_2, %{project_id: project_2.id})

      assert [work_this_month.id, work_bom.id], Billing.recent_work(user) |> Enum.map(& &1.id)

      assert [work_this_month.id, work_bom.id, work_last_month.id],
             Billing.recent_work(user, last_month) |> Enum.map(& &1.id)
    end

    defp strdate(d) do
      Timex.format!(d, "%Y-%m-%d", :strftime)
    end

    test "get_user_work!/1 returns the work with given id" do
      %Work{id: id, user: owner} = work_fixture()
      assert %Work{id: ^id} = Billing.get_user_work!(owner, id)
    end

    test "create_work/1 with valid data creates a work" do
      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client)

      assert {:ok, %Work{} = work} =
               Billing.create_work(user, Enum.into(@valid_attrs, %{project_id: project.id}))

      assert work.hours == Decimal.new("120.5")
      assert work.task == "some task"
      assert work.total == Decimal.new("120.5")
      assert work.worked_on == ~D[2010-04-17]
    end

    test "create_work/1 with invalid data returns error changeset" do
      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client)

      assert {:error, %Ecto.Changeset{}} =
               Billing.create_work(user, Enum.into(@invalid_attrs, %{project_id: project.id}))
    end

    test "update_work/2 with valid data updates the work" do
      work = work_fixture()
      assert {:ok, work} = Billing.update_work(work, @update_attrs)
      assert %Work{} = work
      assert work.hours == Decimal.new("456.7")
      assert work.task == "some updated task"
      assert work.total == Decimal.new("456.7")
      assert work.worked_on == ~D[2011-05-18]
    end

    test "update_work/2 with invalid data returns error changeset" do
      work = work_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_work(work, @invalid_attrs)
    end

    test "delete_work/1 deletes the work" do
      work = work_fixture()
      assert {:ok, %Work{id: id, user: owner}} = Billing.delete_work(work)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_user_work!(owner, id) end
    end

    test "change_work/1 returns a work changeset" do
      work = work_fixture()
      assert %Ecto.Changeset{} = Billing.change_work(work)
    end
  end

  describe "helpers" do
    test "earnings/1" do
      today = ~D[2018-07-19]
      week_ago = Timex.subtract(today, Timex.Duration.from_days(7))
      month_ago = Timex.subtract(today, Timex.Duration.from_days(31))

      %Work{project_id: project_id, user: user} = work_fixture(%{worked_on: today, total: 10})
      work_fixture(user, %{project_id: project_id, worked_on: week_ago, total: 20})
      work_fixture(user, %{project_id: project_id, worked_on: month_ago, total: 40})

      assert [this_week: Decimal.new(10), this_month: Decimal.new(30), unpaid: Decimal.new(70)] ==
               Billing.earnings(user, today)
    end

    test "current_work/1" do
      %Work{project_id: project_1_id, user: user} = work_fixture(%{total: 1})
      %Work{project_id: project_2_id} = work_fixture(user, %{total: 2})

      assert [
               {project_1_id, "Some Project", Decimal.new(1)},
               {project_2_id, "Some Project", Decimal.new(2)}
             ] == Billing.current_work(user)
    end

    test "create_invoice_from_unpaid_work/2 when work is present" do
      project = %Project{prefix: prefix} = project_fixture()
      {:ok, invoice} = Billing.create_invoice(project, %{ref: "REF123", total: 1, hours: 1})

      work_fixture(project, %{hours: 1, total: 5})
      |> Repo.preload(:invoice)
      |> Billing.change_work()
      |> Ecto.Changeset.put_assoc(:invoice, invoice)
      |> Repo.update()

      work_fixture(project, %{hours: 2, total: 10})

      hours = Decimal.new(2)
      total = Decimal.new(10)
      ref = "#{prefix}#{Timex.format!(Timex.today(), "%Y%m%d", :strftime)}"
      {:ok, invoice} = Billing.create_invoice_from_unpaid_work(project)

      assert %Invoice{hours: ^hours, total: ^total, ref: ^ref, paid_on: nil, forgiven: false} =
               invoice

      invoice = Repo.preload(invoice, :works)
      assert Enum.count(invoice.works) == 1
    end

    test "create_invoice_from_unpaid_work/2 when work is missing" do
      project = project_fixture()
      assert {:error, :no_work} = Billing.create_invoice_from_unpaid_work(project)
    end

    test "delete_invoice/1 with work should unlink work" do
      project = project_fixture()
      work = work_fixture(project)
      {:ok, invoice} = Billing.create_invoice_from_unpaid_work(project)

      assert Billing.delete_invoice(invoice)

      work = Repo.get!(Work, work.id)
      assert work.invoice_id == nil, "Deleting invoices should unlink their work"
    end
  end
end
