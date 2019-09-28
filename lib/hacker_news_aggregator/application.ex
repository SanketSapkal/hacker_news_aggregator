defmodule HackerNewsAggregator.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
        # TODO: Make the port configurable
        # TODO: Make the scheme configurable.
        Plug.Cowboy.child_spec(scheme: :http,
                               plug: HackerNewsAggregator.Router,
                               options: [dispatch: dispatch(), port: 4000]),
        {HackerNewsAggregator, []},
        {HackerNewsAggregator.StateUpdater, []},
        # :duplicate is used to register all the websockets under the same key,
        # it is easier to get all the websocket pids this way.
        Registry.child_spec( keys: :duplicate, name: Registry.HackerNewsAggregator)
    ]

    opts = [strategy: :one_for_one, name: HackerNewsAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
      [{:_,
        # Add websocket handler for /ws/.... endpoint.
        [{"/ws/[...]", HackerNewsAggregator.WebSocketHandler, []},
        # Use router for all other endpoints.
         {:_, Plug.Cowboy.Handler, {HackerNewsAggregator.Router, []}}]}]
  end
end
