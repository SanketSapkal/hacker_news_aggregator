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
                               options: [dispatch: dispatch(), port: 4000]),
        {HackerNewsAggregator, []},
        {HackerNewsAggregator.StateUpdater, []},
        Registry.child_spec( keys: :duplicate, name: Registry.HackerNewsAggregator)
    ]

    opts = [strategy: :one_for_one, name: HackerNewsAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
      [{:_, [{"/ws/[...]", HackerNewsAggregator.WebSocketHandler, []},
             {:_, Plug.Cowboy.Handler, {HackerNewsAggregator.Router, []}}]}]
  end
end
