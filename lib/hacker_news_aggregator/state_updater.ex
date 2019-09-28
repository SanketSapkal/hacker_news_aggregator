defmodule HackerNewsAggregator.StateUpdater do

    use Task

    alias HackerNewsAggregator.HTTPClient

    @timeout :timer.minutes(Application.get_env(:hacker_news_aggregator, :update_timeout))

    def start_link(_arg) do
        Task.start_link(fn -> update_state() end)
    end

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
