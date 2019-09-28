defmodule HackerNewsAggregator.HTTPClient do
    @moduledoc """
    Pulls the top stories from hacker-news. Stories are explicitly filtered
    from the pulled data.

    Mutliple story contents are pulled concurrently. Performs content fetch
    process in batches until the configured story count is reached.
    """

    @app :hacker_news_aggregator
    @story_count Application.get_env(@app, :story_count)
    @batch_size Application.get_env(@app, :batch_size)

    @doc """
    Pull top stories from hacker news. First the top story ids are fetched and
    later individual story contents are fetched using a batch mechanism. The
    fetched contents are filtered to keep only "story".

    ## Example

        iex> HackerNewsAggregator.HTTPClient.pull_top_stories()
    """
    @spec pull_top_stories() :: [{integer(), map()}]
    def pull_top_stories() do
        Application.get_env(@app, :top_stories_url)
        |> http_request()
        |> pull_story_content_and_filter_stories()
    end

    #
    # Make a http get request to the specified url and return the decoded body
    # upon a 200 status code.
    #
    @spec http_request(String.t()) :: term()
    defp http_request(url) do
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

    #
    # Empty list of top story ids is received from hacker news.
    #
    @spec pull_story_content_and_filter_stories({atom(), term()}) :: list()
    defp pull_story_content_and_filter_stories({:ok, []}) do
        []
    end

    #
    # Non-empty list of top story ids is received. This list contains upto 500
    # elements, and some of them are jobs, polls which are filtered out after
    # getting their content. The story id list is divided into a batch of size
    # 'batch_size', set in 'config/config.exs'.
    #
    defp pull_story_content_and_filter_stories({:ok, story_id_list}) do
        story_id_list
        |> batch_pull_story_content([])
        |> Enum.slice(0, 50)
    end

    #
    # The http request to get top story ids failed or resulted in a non success
    # status code.
    #
    defp pull_story_content_and_filter_stories({:error, _reason}) do
        []
    end

    #
    # The story id list is empty, return the accumulator.
    #
    @spec batch_pull_story_content([integer()], [{integer(), map()}]) :: [{integer(), map()}]
    defp batch_pull_story_content([], acc) do
        acc
    end

    #
    # Divide the top story id list into batches of size `batch_size`. The batches
    # are created in a lazy way i.e. batches are only created till the
    # accumulator has not accumulated enough story contents.
    #
    # In each batch multiple story contents are fetched from hacker news
    # concurrently using Task. 'batch_size' number of threads are spawned to fetch
    # the story content of all story ids in the batch.
    #
    # After fetching all the story contents, the jobs, polls are filtered out and
    # only content with '"type" => "story"' are returned.
    #
    defp batch_pull_story_content(story_id_list, acc) when length(acc) < @story_count do
        {current_batch, remaining_story_ids}
            = Enum.split(story_id_list, @batch_size)

        results =
            current_batch
            |> Enum.map(&Task.async(fn -> pull_story_content(&1) end))
            |> Enum.map(fn task -> Task.await(task) end)
            |> List.flatten()

        batch_pull_story_content(remaining_story_ids, acc ++ results)
    end

    #
    # The accumulator has enough story contents, thus it breaks the recursion.
    #
    defp batch_pull_story_content(_story_id_list, acc) do
        acc
    end

    #
    # Pull individual story content and filter out jobs and polls.
    #
    defp pull_story_content(story_id) do
        Application.get_env(@app, :individual_story_url)
        |> String.replace("REPLACE_WITH_STORY_ID", to_string(story_id))
        |> http_request()
        |> is_story()
    end

    #
    # Return only "story" content type.
    #
    defp is_story({:ok, %{"type" => "story", "id" => story_id} = story_content}) do
        [{story_id, story_content}]
    end

    #
    # Filter out other content types.
    #
    defp is_story(_error_or_non_story_type) do
        []
    end
end
