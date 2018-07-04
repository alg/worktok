# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :worktok,
  ecto_repos: [Worktok.Repo]

# Configures the endpoint
config :worktok, WorktokWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AwasAC5Dzt1Xg9wj7zc3/S/Wh1OIk42h0JF8ykfyeXTmJ6fZQkEbLRx81IvHF8mK",
  render_errors: [view: WorktokWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Worktok.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
