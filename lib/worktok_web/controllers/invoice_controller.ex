defmodule WorktokWeb.InvoiceController do
  use WorktokWeb, :user_controller
  import Ecto.Query

  alias Worktok.Billing

  def index(conn, _params, current_user) do
    invoices = Billing.list_user_invoices(current_user)
    render(conn, "index.html", invoices: invoices)
  end

  def show(conn, %{"id" => id}, current_user) do
    invoice =
      Billing.get_user_invoice!(current_user, id)
      |> Worktok.Repo.preload([:client, :project, works: from(w in Billing.Work, order_by: w.worked_on)])

    render(conn, "show.html", invoice: invoice)
  end

  def delete(conn, %{"id" => id}, current_user) do
    invoice = Billing.get_user_invoice!(current_user, id)
    {:ok, _invoice} = Billing.delete_invoice(invoice)

    conn
    |> put_flash(:info, "Invoice deleted successfully.")
    |> redirect(to: invoice_path(conn, :index))
  end

  def pay(conn, %{"id" => id}, current_user) do
    invoice = Billing.get_user_invoice!(current_user, id)
    {:ok, _invoice} = Billing.pay_invoice(invoice)

    conn
    |> put_flash(:info, "Invoice marked as paid")
    |> redirect(to: invoice_path(conn, :index))
  end

  def unpay(conn, %{"id" => id}, current_user) do
    invoice = Billing.get_user_invoice!(current_user, id)
    {:ok, _invoice} = Billing.unpay_invoice(invoice)

    conn
    |> put_flash(:info, "Invoice marked as unpaid")
    |> redirect(to: invoice_path(conn, :index))
  end
end
