defmodule HackerNewsAggregator.HTTPClient do
    def get_top_stories() do
        Application.get_env(:hacker_news_aggregator, :top_stories_url)
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
                {:error, reason}
        end
    end

    def filter_stories({:ok, []}) do
        %{}
    end

    def filter_stories({:ok, story_id_list}) do
        story_id_list
        |> Enum.reduce([], fn story_id, acc ->
                                    get_story_content(story_id) ++ acc end)
        |> Enum.slice(0, 50)
        |> Enum.into(%{})
    end

    def filter_stories({:error, _reason}) do
        %{}
    end

    def batch_process(story_id_list) do

    end

    def get_story_content(story_id) do
        Application.get_env(:hacker_news_aggregator, :individual_story_url)
        |> String.replace("REPLACE_WITH_STORY_ID", to_string(story_id))
        |> http_request()
        |> is_story()
    end

    def is_story({:ok, %{"type" => "story", "id" => story_id} = story_content}) do
        [{story_id, story_content}]
    end

    def is_story(_error_or_non_story_type) do
        [{}]
    end
end
