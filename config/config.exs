# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :hacker_news_aggregator, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:hacker_news_aggregator, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
config :hacker_news_aggregator,
    top_stories_url: "https://hacker-news.firebaseio.com/v0/topstories.json",
    individual_story_url: "https://hacker-news.firebaseio.com/v0/item/REPLACE_WITH_STORY_ID.json",
    threads_per_batch: 20,
    story_count: 50,
    update_timeout: 5
