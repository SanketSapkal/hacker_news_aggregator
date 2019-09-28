use Mix.Config
config :hacker_news_aggregator,
    # URL for getting top 500 stories from hacker news
    top_stories_url: "https://hacker-news.firebaseio.com/v0/topstories.json",

    # URL for getting individual story content from hacker-news
    individual_story_url: "https://hacker-news.firebaseio.com/v0/item/REPLACE_WITH_STORY_ID.json",

    # These threads correspond to size of a single batch while getting the story
    # content of story id in the batch
    threads_per_batch: 20,

    # Top story count, these many top stories are pulled from hacker news. These
    # many stories are sent to the websocket.
    story_count: 50,

    # Time interval after which top stories from hacker news are pulled and sent
    # to websocket
    update_timeout: 5
