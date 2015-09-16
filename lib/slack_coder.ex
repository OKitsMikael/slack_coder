defmodule SlackCoder do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(SlackCoder.Slack, [Application.get_env(:slack_coder, :slack_api_token), []]),
      worker(SlackCoder.Repo, []),
      supervisor(SlackCoder.Github.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackCoder.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
