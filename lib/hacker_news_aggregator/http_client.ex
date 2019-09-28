defmodule HackerNewsAggregator.HTTPClient do

    @app :hacker_news_aggregator
    @story_count Application.get_env(@app, :story_count)
    @threads_per_batch Application.get_env(@app, :threads_per_batch)

    def pull_top_stories() do
        Application.get_env(@app, :top_stories_url)
        |> http_request()
        |> filter_stories()
    end

    def http_request(url) do
        case HTTPoison.get(url) do
            {:ok, %HTTPoison.Response{body: response, status_code: 200}} ->
                {:ok, Poison.decode!(response)}

            {:ok, %HTTPoison.Response{status_code: other_status_code}} ->
                message = "Failed with status code: #{other_status_code}"
                IO.puts(message)
                {:error, message}

            {:error, reason} ->
                message = "Failed with reason: #{reason}"
                IO.puts(message)
                {:error, reason}
        end
    end

    def filter_stories({:ok, []}) do
        %{}
    end

    def filter_stories({:ok, story_id_list}) do
        story_id_list
        |> batch_process([])
        |> Enum.slice(0, 50)
        |> Enum.into(%{})
    end

    def filter_stories({:error, _reason}) do
        %{}
    end

    def batch_process([], acc) do
        acc
    end

    def batch_process(story_id_list, acc) when length(acc) < @story_count do
        {current_batch, remaining_story_ids}
            = Enum.split(story_id_list, @threads_per_batch)

        results =
            current_batch
            |> Enum.map(&Task.async(fn -> pull_story_content(&1) end))
            |> Enum.map(fn task -> Task.await(task) end)
            |> List.flatten()

        batch_process(remaining_story_ids, acc ++ results)
    end

    def batch_process(_story_id_list, acc) do
        acc
    end

    def pull_story_content(story_id) do
        Application.get_env(@app, :individual_story_url)
        |> String.replace("REPLACE_WITH_STORY_ID", to_string(story_id))
        |> http_request()
        |> is_story()
    end

    def is_story({:ok, %{"type" => "story", "id" => story_id} = story_content}) do
        [{story_id, story_content}]
    end

    def is_story(_error_or_non_story_type) do
        []
    end
end
