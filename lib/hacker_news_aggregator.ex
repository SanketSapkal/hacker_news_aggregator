defmodule HackerNewsAggregator do
  @moduledoc """
  Documentation for HackerNewsAggregator.
  """

  use GenServer

  alias HackerNewsAggregator.HTTPClient
  @default_timeout :timer.minutes(5)
  @genserver_name :hacker_news_aggregator

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
    GenServer.start_link(__MODULE__, %{}, name: @genserver_name)
  end

  def init(_) do
    state = initial_state()
    {:ok, state}
  end

  def get_top_stories(content_type) do
      GenServer.call(@genserver_name, {:get_top_stories, content_type}, @default_timeout)
  end

  def get_single_story(story_id) do
      case GenServer.call(@genserver_name, {:get_single_story, story_id}, @default_timeout) do
          {:ok, story} ->
              story
          :error ->
              {:error, "story not found"}
      end
  end

  def update_state(new_state) do
      GenServer.cast(@genserver_name, {:update_state, new_state})
  end

  def handle_call({:get_top_stories, :only_ids}, _from, state) do
      {:reply, Map.keys(state), state}
  end

  def handle_call({:get_top_stories, :content}, _from, state) do
      {:reply, Map.values(state), state}
  end

  def handle_call({:get_single_story, story_id}, _from, state) do
      {:reply, Map.fetch(state, story_id), state}
  end

  def handle_cast({:update_state, new_state}, _state) do
      IO.puts("updating state...")
      {:noreply, new_state}
  end

  defp initial_state() do
      HTTPClient.pull_top_stories()
  end
end
