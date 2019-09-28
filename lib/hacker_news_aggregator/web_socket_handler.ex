defmodule HackerNewsAggregator.WebSocketHandler do

    @behaviour :cowboy_websocket
    @websocket_registry_key :websocket
    @timeout 3 * :timer.minutes(Application.get_env(:hacker_news_aggregator, :update_timeout))

    def init(request, _state) do
        state = %{registry_key: @websocket_registry_key}

        {:cowboy_websocket, request, state, %{:idle_timeout => @timeout}}
    end

    def websocket_init(state) do
        Registry.HackerNewsAggregator
        |> Registry.register(state.registry_key, {})

        {:ok, state}
    end

    def websocket_handle({:text, json}, state) do
        {:reply, {:text, json}, state}
    end

    def websocket_info(info, state) do
        message = Poison.encode!(info)
        {:reply, {:text, message}, state}
    end
end
