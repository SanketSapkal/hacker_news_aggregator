defmodule HackerNewsAggregatorTest do
  use ExUnit.Case
  doctest HackerNewsAggregator

  test "greets the world" do
    assert HackerNewsAggregator.hello() == :world
  end

  # TODO: Add a test case for checking whether the top stories returned by
  # HackerNewsAggregator.HTTPClient.pull_top_stories are actually the top 50
  # stories

  # TODO: Add a test case for each rest endpoint.

  # TODO: Add a test case to get a story content whose story id is not in memory.

  # TODO: Add a test case for each rest endpoint, mock the reponse to error messages.

  # TODO: Add test case for broadcast, spawn a pid and Register it into Registry
  # and updates should be received periodically

  # TODO: Connect to websocket and receive updates as a client.

  # TODO: Connect multiple clients to websocket and test whether all the clients
  # receive the top stories.

  # TODO: Test GenServer wrappers i.e HackerNewsAggregator functions.
end
