# Worktok

Worktok is a small and simple multiuser billing and invoicing application. A user is
free to define client and projects, report their time and create nice invoices.
Convenient dashboard shows current uninvoiced work, earning summaries and pending
invoices.

## Features

  * Listing clients
  * Listing client projects
  * Recording work and expenses
  * Generating invoices and tracking payments

## Starting locally

Application depends on PostgreSQL database server and written in Elixir. You need both
setup on your system in order to run.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
