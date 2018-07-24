defmodule Worktok.BillingTest do
  use Worktok.DataCase

  alias Worktok.Billing
  alias Worktok.Billing.Work
  alias Worktok.Billing.Invoice
  alias Worktok.Registry.Project

  defp invoice_fixture(attrs \\ %{}) do
    user = user_fixture()
    client = client_fixture(user)
    project = project_fixture(client)
    invoice = invoice_fixture(project, attrs)

    invoice
  end


  describe "invoices" do
    @valid_attrs %{forgiven: true, hours: "120.5", paid_on: ~D[2010-04-17], ref: "some ref", total: "120.5"}
    @update_attrs %{forgiven: false, hours: "456.7", paid_on: ~D[2011-05-18], ref: "some updated ref", total: "456.7"}
    @invalid_attrs %{forgiven: nil, hours: nil, paid_on: nil, ref: nil, total: nil}

    test "list_invoices/0 returns all invoices" do
      %Invoice{id: id, user: owner} = invoice_fixture()
      assert [%Invoice{id: ^id}] = Billing.list_user_invoices(owner)
    end

    test "get_invoice!/1 returns the invoice with given id" do
      %Invoice{id: id, user: owner} = invoice_fixture()
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
      invoice = invoice_fixture()
      assert {:ok, invoice} = Billing.update_invoice(invoice, @update_attrs)
      assert %Invoice{} = invoice
      assert invoice.forgiven == false
      assert invoice.hours == Decimal.new("456.7")
      assert invoice.paid_on == ~D[2011-05-18]
      assert invoice.ref == "some updated ref"
      assert invoice.total == Decimal.new("456.7")
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_invoice(invoice, @invalid_attrs)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Billing.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_user_invoice!(invoice.user, invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Billing.change_invoice(invoice)
    end
  end

  describe "works" do
    @valid_attrs %{hours: "120.5", task: "some task", total: "120.5", worked_on: ~D[2010-04-17]}
    @update_attrs %{hours: "456.7", task: "some updated task", total: "456.7", worked_on: ~D[2011-05-18]}
    @invalid_attrs %{hours: nil, task: nil, total: nil, worked_on: nil}

    test "list_user_works/1 returns all works" do
      %Work{id: id, user: owner} = work_fixture()
      assert [%Work{id: ^id}] = Billing.list_user_works(owner)
    end

    test "recent_work/1 returns recent user work" do
      today = Date.utc_today()

      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client)
      user_works =
        0..8
        |> Enum.map(&(work_fixture(user, %{task: "task-" <> to_string(&1), project_id: project.id, worked_on: Date.add(today, -&1)})))

      user_2 = user_fixture()
      client_2 = client_fixture(user, prefix: "C2")
      project_2 = project_fixture(client_2, prefix: "P2")
      work_fixture(user_2, %{project_id: project_2.id})

      expected_ids =
        user_works
        |> Enum.take(7)
        |> Enum.map(&(&1.id))
        |> Enum.sort

      result_ids =
        Billing.recent_work(user, Timex.subtract(Timex.today(), Timex.Duration.from_days(7)))
        |> Enum.map(&(&1.id))

      assert result_ids == expected_ids
    end

    test "get_user_work!/1 returns the work with given id" do
      %Work{id: id, user: owner} = work_fixture()
      assert %Work{id: ^id} = Billing.get_user_work!(owner, id)
    end

    test "create_work/1 with valid data creates a work" do
      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client)

      assert {:ok, %Work{} = work} = Billing.create_work(user, Enum.into(@valid_attrs, %{project_id: project.id}))
      assert work.hours == Decimal.new("120.5")
      assert work.task == "some task"
      assert work.total == Decimal.new("120.5")
      assert work.worked_on == ~D[2010-04-17]
    end

    test "create_work/1 with invalid data returns error changeset" do
      user = user_fixture()
      client = client_fixture(user)
      project = project_fixture(client)

      assert {:error, %Ecto.Changeset{}} = Billing.create_work(user, Enum.into(@invalid_attrs, %{project_id: project.id}))
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
      today = Timex.today()
      week_ago = Timex.subtract(today, Timex.Duration.from_days(7))
      month_ago = Timex.subtract(today, Timex.Duration.from_days(31))

      %Work{project_id: project_id, user: user} = work_fixture(%{worked_on: today, total: 10})
      work_fixture(user, %{project_id: project_id, worked_on: week_ago, total: 20})
      work_fixture(user, %{project_id: project_id, worked_on: month_ago, total: 40})

      assert [this_week: Decimal.new(10), this_month: Decimal.new(30), unpaid: Decimal.new(70)] == Billing.earnings(user)
    end

    test "current_work/1" do
      %Work{project_id: project_1_id, user: user} = work_fixture(%{total: 1})
      %Work{project_id: project_2_id} = work_fixture(user, %{total: 2})

      assert [{project_1_id, "Some Project", Decimal.new(1)}, {project_2_id, "Some Project", Decimal.new(2)}] == Billing.current_work(user)
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
      assert %Invoice{hours: ^hours, total: ^total, ref: ^ref, paid_on: nil, forgiven: false} = invoice

      invoice = Repo.preload(invoice, :works)
      assert Enum.count(invoice.works) == 1
    end


    # test "create_invoice_from_unpaid_work/2 when work is missing"
  end
end
