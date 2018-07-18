defmodule WorktokWeb.Router do
  use WorktokWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WorktokWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public access
  scope "/", WorktokWeb do
    pipe_through :browser

    get  "/", PageController, :index

    get  "/signup", UserController, :new
    post "/signup", UserController, :create

    get  "/login", SessionController, :new
    post "/login", SessionController, :create
  end

  # Authenticated users only
  scope "/", WorktokWeb do
    pipe_through [:browser, :authenticate_user]

    get  "/dashboard", DashboardController, :index
    post "/add_work", DashboardController, :add_work
    delete "/delete_work/:id", DashboardController, :delete_work

    resources "/clients", ClientController
    resources "/projects", ProjectController
    resources "/invoices", InvoiceController

    delete "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", WorktokWeb do
  #   pipe_through :api
  # end
end
