defmodule WorktokWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use WorktokWeb, :controller
      use WorktokWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: WorktokWeb
      import Plug.Conn
      import WorktokWeb.Router.Helpers
      import WorktokWeb.Gettext
      import WorktokWeb.Auth, only: [authenticate_user: 2]
    end
  end

  def user_controller do
    quote do
      use Phoenix.Controller, namespace: WorktokWeb
      import Plug.Conn
      import WorktokWeb.Router.Helpers
      import WorktokWeb.Gettext
      import WorktokWeb.Auth, only: [authenticate_user: 2]

      def action(conn, _) do
        args = [conn, conn.params, conn.assigns.current_user]
        apply(__MODULE__, Phoenix.Controller.action_name(conn), args)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/worktok_web/templates",
        namespace: WorktokWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import WorktokWeb.Router.Helpers
      import WorktokWeb.ErrorHelpers
      import WorktokWeb.Gettext

      def date(nil), do: nil

      def date(d) do
        Timex.format!(d, "%b %d, %Y", :strftime)
      end

      def money(nil), do: money(Decimal.new(0))

      def money(v) do
        cents = trunc(Decimal.to_float(v) * 100)
        Money.to_string(Money.new(cents, :USD), symbol: true)
      end

      def yes_no(nil), do: "No"
      def yes_no(false), do: "No"
      def yes_no(0), do: "No"
      def yes_no(_), do: "Yes"
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import WorktokWeb.Auth, only: [authenticate_user: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import WorktokWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
