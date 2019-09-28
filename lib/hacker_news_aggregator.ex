defmodule HackerNewsAggregator do
  @moduledoc """
  Documentation for HackerNewsAggregator.
  """

  use GenServer

  alias HackerNewsAggregator.HTTPClient

  @default_timeout :timer.minutes(5)
  @genserver_name :hacker_news_aggregator
  @websocket_registry_key :websocket
  @story_count Application.get_env(:hacker_news_aggregator, :story_count)

  @doc """
  Hello world.

  ## Examples

      iex> HackerNewsAggregator.hello()
      :world

  """
  def hello do
      "world"
  end

  def start_link(_) do
      GenServer.start_link(__MODULE__, [], name: @genserver_name)
  end

  def init(_) do
      state = initial_state()
      {:ok, state}
  end

  def get_top_stories(content_type, start_index, story_count) do
      GenServer.call(@genserver_name,
                     {:get_top_stories, content_type, start_index, story_count},
                     @default_timeout)
  end

  def get_single_story(story_id) do
      case GenServer.call(@genserver_name, {:get_single_story, story_id}, @default_timeout) do
          nil ->
              {:error, "story not found"} |> Tuple.to_list

          story_content ->
              story_content
      end
  end

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
      IO.puts("updating state...")
      new_state = new_state ++ old_state
                  |> Enum.uniq_by(fn {key, _value} -> key end)

      new_state
      |> Keyword.values()
      |> Enum.slice(0, @story_count)
      |> broadcast_state_on_websockets()

      {:noreply, new_state}
  end

  defp initial_state() do
      HTTPClient.pull_top_stories()
  end

  defp broadcast_state_on_websockets(message) do
      case Registry.lookup(Registry.HackerNewsAggregator, @websocket_registry_key) do
          [] ->
              :ok
          _ ->
              Registry.HackerNewsAggregator
              |> Registry.dispatch(@websocket_registry_key, fn(entries) ->
                  for {pid, _} <- entries do
                      Process.send(pid, message, [])
                  end
              end)
      end
  end

end
