defmodule HackerNewsAggregator.MixProject do
  use Mix.Project

  def project do
    [
      app: :hacker_news_aggregator,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HackerNewsAggregator.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
        {:poolboy, ">0.0.0"},
        {:plug_cowboy, "~> 2.0"},
        {:httpoison, "~> 1.0"},
        {:poison, "~> 3.1"}
    ]
  end
end
