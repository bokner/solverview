# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :solverview, SolverViewWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "A03qNtSFSo7Q4Eo7d2uLQos+wfeIFlIRXa+kZMgbFyZySw78jJppHdKeBHyl3bn9",
  render_errors: [view: SolverViewWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SolverView.PubSub,
  live_view: [signing_salt: "pH/U3jBb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
