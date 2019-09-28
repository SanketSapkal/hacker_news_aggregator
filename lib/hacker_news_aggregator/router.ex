defmodule HackerNewsAggregator.Router do
    use Plug.Router
    plug :match
    plug :dispatch

    #
    # Return story content of a single story id
    #
    get "/get_story" do
        conn = fetch_query_params(conn)
        %{"storyId" => story_id} = conn.params

        result = HackerNewsAggregator.get_single_story(String.to_integer(story_id))

        conn
        |> put_resp_content_type("application/json")
        # TODO: Add error status in case of error
        |> send_resp(200, Poison.encode!(result))
    end

    #
    # Return only top story ids. Supports pagination, page number and story
    # count need to be specified while calling this REST endpoint.
    #
    get "/get_stories" do
        conn = fetch_query_params(conn)

        {start_index, story_count} = get_params(conn)
        result = HackerNewsAggregator.get_top_stories(:only_ids, start_index, story_count)

        conn
        |> put_resp_content_type("application/json")
        # TODO: Add error status in case of error
        |> send_resp(200, Poison.encode!(result))
    end

    #
    # Return contents of top stories. Supports pagination, page number and story
    # count need to be specified while calling this REST endpoint.
    #
    get "/get_stories/content" do
        conn = fetch_query_params(conn)

        {start_index, story_count} = get_params(conn)
        result = HackerNewsAggregator.get_top_stories(:content, start_index, story_count)

        conn
        |> put_resp_content_type("application/json")
        # TODO: Add error status in case of error
        |> send_resp(200, Poison.encode!(result))
    end

    #
    # Extract parameters from connections are convert the parameters to integer.
    #
    defp get_params(conn) do
        %{"pageNumber" => page_number, "storyCount" => story_count} = conn.params

        story_count = String.to_integer(story_count)
        start_index = (String.to_integer(page_number) - 1) * story_count

        {start_index, story_count}
    end
end
