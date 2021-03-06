use Mix.Config

config :slack_coder, SlackCoder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "slack_coder_test",
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :slack_coder,
  slack_api_token: System.get_env("SLACK_API_TOKEN"),
  github: [
    pat: "pat-123",
    user: "slack_coder",
  ],
  random_failure_channel: "#travis-fails",
  notifications: [
    always_allow: true, # So tests dont fail
    # Actual config values for prod could be (24 hour format)
    min_hour: 8,
    max_hour: 17,
    # 1 is Monday, 7 is Sunday
    # See Timex for Date.now |> Date.weekday for more info
    days: [1,2,3,4,5,6,7]
  ]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :slack_coder, SlackCoder.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :logger,
  backends: [:console]

# Set a higher stacktrace during test
config :phoenix, :stacktrace_depth, 20

import_config "test_stubs.exs"
