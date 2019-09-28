# Hacker News Aggregator

Aggregates top stories from [hacker news](https://news.ycombinator.com/) into
GenServer memory. Supports REST endpoints and websocket to retrieve top stories
from memory.

Supports pagination on REST api's.

## Environment
- Erlang/OTP 21
- Elixir 1.8.2

## Compile and Run:
```
mix deps.get
mix deps.compile
iex -S run
```

## Configurations:

- Concurrency for pulling stories from hacker-news can be configured using
`batch_size` parameter in `config/config.exs`

- The top stories are updated in memory periodically, and sent to websocket. This
update interval can configured using `update_timeout` in `config/config.exs`, it
is specified in minutes.

- [***TODO***] Default port (***4000***) can be changed via `port` in `config/config.exs`.

## Examples:
1. Get a single story from memory
```
curl 'http://localhost:4000/get_story?storyId=21095438'
```

2. Get top 20 stories on page 1 (only story id's)
```
curl 'http://localhost:4000/get_stories?pageNumber=1&storyCount=20'
```

3. Get top 20 stories on page 1 with story content
```
curl 'http://localhost:4000/get_stories/content?pageNumber=1&storyCount=20'
```

4. Create a websocket using [wscat](https://github.com/websockets/wscat)
```
wscat -c ws://localhost:4000/ws/top_stories    
```
