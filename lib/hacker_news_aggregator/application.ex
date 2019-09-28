defmodule HackerNewsAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
        Plug.Cowboy.child_spec(scheme: :http,
                               plug: HackerNewsAggregator.Router,
                               options: [port: 4000]),
        {HackerNewsAggregator, []},
        {HackerNewsAggregator.StateUpdater, []}
    ]

    opts = [strategy: :one_for_one, name: HackerNewsAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
