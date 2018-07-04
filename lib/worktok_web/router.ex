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

  scope "/", WorktokWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/secure", PageController, :secure

    get "/signup", UserController, :new
    post "/signup", UserController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", WorktokWeb do
  #   pipe_through :api
  # end
end
