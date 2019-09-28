defmodule HackerNewsAggregator.WebSocketHandler do
    @moduledoc """
    Web socket handler for hacker news aggregator. Listens on "/ws/..".
    Receives top stories and sends them to client.
    """

    @behaviour :cowboy_websocket
    @websocket_registry_key :websocket
    @timeout 3 * :timer.minutes(Application.get_env(:hacker_news_aggregator, :update_timeout))

    def init(request, _state) do
        # This registry key is used to get the websocket pids in module:
        # HackerNewsAggregator.
        state = %{registry_key: @websocket_registry_key}

        {:cowboy_websocket, request, state, %{:idle_timeout => @timeout}}
    end

    def websocket_init(state) do
        # Register the pid in Registry.HackerNewsAggregator, this way all the
        # websocket pids are easily accessible and this can be later used to
        # send top stories update to connected clients.
        Registry.HackerNewsAggregator
        |> Registry.register(state.registry_key, {})

        {:ok, state}
    end

    def websocket_handle({:text, json}, state) do
        # Return the text sent by client.
        {:reply, {:text, json}, state}
    end

    def websocket_info(info, state) do
        # The top stories update from HackerNewsAggregator.broadcast_state_on_websockets/1
        # is received here. Encode the message and send it to client.
        message = Poison.encode!(info)
        {:reply, {:text, message}, state}
    end
end
