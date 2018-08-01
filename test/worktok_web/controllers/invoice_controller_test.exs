defmodule WorktokWeb.InvoiceControllerTest do
  use WorktokWeb.ConnCase

  alias Worktok.Billing.Invoice

  describe "index" do
    @tag login_as: "Max"
    test "lists all invoices", %{conn: conn} do
      conn = get conn, invoice_path(conn, :index)
      assert html_response(conn, 200) =~ "Invoices"
    end
  end

  describe "show" do
    setup [:create_invoice]

    @tag login_as: "Max"
    test "shows invoice details", %{conn: conn, invoice: invoice} do
      conn = get conn, invoice_path(conn, :show, invoice)
      assert html_response(conn, 200) =~ invoice.ref
    end
  end

  describe "delete invoice" do
    setup [:create_invoice]

    @tag login_as: "Max"
    test "deletes chosen invoice", %{conn: conn, user: user, invoice: invoice} do
      conn = delete conn, invoice_path(conn, :delete, invoice)
      assert redirected_to(conn) == invoice_path(conn, :index)
      assert_raise Ecto.NoResultsError, fn ->
        Worktok.Billing.get_user_invoice!(user, invoice.id)
      end
    end
  end

  describe "pay" do
    setup [:create_invoice]

    @tag login_as: "Max"
    test "should mark invoice as paid", %{conn: conn, user: user, invoice: invoice} do
      conn = post conn, invoice_path(conn, :pay, invoice.id)
      assert get_flash(conn, :info) == "Invoice marked as paid"
      assert redirected_to(conn) == invoice_path(conn, :index)

      today = Timex.today()
      assert %Invoice{paid_on: ^today} = Worktok.Billing.get_user_invoice!(user, invoice.id)
    end
  end

  describe "unpay" do
    setup [:create_invoice]

    @tag login_as: "Max"
    test "should mark invoice as paid", %{conn: conn, user: user, invoice: invoice} do
      {:ok, invoice} = Worktok.Billing.pay_invoice(invoice)

      conn = post conn, invoice_path(conn, :unpay, invoice.id)
      assert get_flash(conn, :info) == "Invoice marked as unpaid"
      assert redirected_to(conn) == invoice_path(conn, :index)
      assert %Invoice{paid_on: nil} = Worktok.Billing.get_user_invoice!(user, invoice.id)
    end
  end


  defp create_invoice(%{user: user}) do
    client = client_fixture(user)
    project = project_fixture(client)
    invoice = invoice_fixture(project)

    {:ok, invoice: invoice}
  end
end
