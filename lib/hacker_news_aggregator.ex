defmodule HackerNewsAggregator do
  @moduledoc """
  Hacker News Aggregator which collects top stories periodically from hacker-news
  and stores it in the memory.

  It is built using GenServer, and the top stories are stored in the process
  memory.
  """

  use GenServer

  alias HackerNewsAggregator.HTTPClient

  # TODO: Define custom types

  # timeout for GenServer calls
  @default_timeout :timer.minutes(5)
  @genserver_name :hacker_news_aggregator
  @websocket_registry_key :websocket
  @story_count Application.get_env(:hacker_news_aggregator, :story_count)

  def start_link(_) do
      GenServer.start_link(__MODULE__, [], name: @genserver_name)
  end

  def init(_) do
      # Update initial state synchronously
      # TODO: Add asynchronous state update here using `update_state/1`
      state = initial_state()
      {:ok, state}
  end

  @doc """
  Get ids or content of top stories.

  ## Parameters

    - content_type: can be either `:content` for getting content of stories, or
                    `:only_ids` for getting only ids of top stories.

    - start_index: starting index after which the next stories are to be fetched from memory.

    - story_count: number of stories to be fetched after start_index.

  ## Examples

    iex> HackerNewsAggregator.get_top_stories(:content, 0, 10)
    [%{"by" => "author1", "score" => 1, "text" => "article text", ...}, ...]

    iex> HackerNewsAggregator.get_top_stories(:only_ids, 0, 10)
    [123,124, 125]
  """
  @spec get_top_stories(:content | :only_ids, non_neg_integer(), non_neg_integer()) :: [map()]
  def get_top_stories(content_type, start_index, story_count) do
      GenServer.call(@genserver_name,
                     {:get_top_stories, content_type, start_index, story_count},
                     @default_timeout)
  end

  @doc """
  Get content of a story corresponding to a story id.

  ## Parameters

    - story_id: Integer id of a story

  ## Examples

    iex> HackerNewsAggregator.get_single_story(123)
    %{"by" => "author1", "score" => 1, "text" => "article text", ...}
  """
  @spec get_single_story(integer) :: [map()]
  def get_single_story(story_id) do
      case GenServer.call(@genserver_name, {:get_single_story, story_id}, @default_timeout) do
          nil ->
              {:error, "story not found"} |> Tuple.to_list

          story_content ->
              story_content
      end
  end

  @doc """
  Update the GenServer state using the fetched top stories.
  """
  @spec update_state([{integer(), map()}]) :: :ok
  def update_state(new_state) do
      GenServer.cast(@genserver_name, {:update_state, new_state})
  end

  def handle_call({:get_top_stories, :only_ids, start_index, story_count}, _from, state) do
      reply = Enum.slice(state, start_index, story_count)
      {:reply, Keyword.keys(reply), state}
  end

  def handle_call({:get_top_stories, :content, start_index, story_count}, _from, state) do
      reply = Enum.slice(state, start_index, story_count)
      {:reply, Keyword.values(reply), state}
  end

  def handle_call({:get_single_story, story_id}, _from, state) do
      # TODO: Optimize this
      {_story_id, reply} = Enum.find(state, fn {id, _value} -> id == story_id end)
      {:reply, reply, state}
  end

  def handle_cast({:update_state, new_state}, old_state) do
      new_state = new_state ++ old_state
                  |> Enum.uniq_by(fn {key, _value} -> key end)

      new_state
      |> Keyword.values()
      |> Enum.slice(0, @story_count)
      |> broadcast_state_on_websockets()

      {:noreply, new_state}
  end

  #
  # Fetch the initial state synchronously.
  #
  @spec initial_state() :: [{integer(), map()}]
  defp initial_state() do
      # TODO: broadcast during this time?
      HTTPClient.pull_top_stories()
  end

  #
  # Broadcast the new top stories to all the alive websockets. The websocket pids
  # are stored in Registry.HackerNewsAggregator corresponding to :websocket key.
  #
  # TODO: broadcast the message asynchronously
  @spec broadcast_state_on_websockets([map()]) :: :ok
  defp broadcast_state_on_websockets(message) do
      case Registry.lookup(Registry.HackerNewsAggregator, @websocket_registry_key) do
          [] ->
              :ok
          _ ->
              # Send the new top stories to all the websocket pids, which will
              # then send these stories to the clients.
              Registry.HackerNewsAggregator
              |> Registry.dispatch(@websocket_registry_key, fn(entries) ->
                  for {pid, _} <- entries do
                      Process.send(pid, message, [])
                  end
              end)
      end
  end

end
