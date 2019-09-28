defmodule HackerNewsAggregator.StateUpdater do
    @moduledoc """
    Minimal timer process which also fetches the top stories from HTTPClient.
    """

    use Task

    alias HackerNewsAggregator.HTTPClient

    @timeout :timer.minutes(Application.get_env(:hacker_news_aggregator, :update_timeout))

    def start_link(_arg) do
        # Spwan a task which runs on forever
        Task.start_link(fn -> update_state() end)
    end

    #
    # Pull top stories periodically, the time interval is specified by @timeout.
    #
    def update_state() do
        receive do
        after
            @timeout ->
                HTTPClient.pull_top_stories()
                |> HackerNewsAggregator.update_state()

                update_state()
        end
    end
end
