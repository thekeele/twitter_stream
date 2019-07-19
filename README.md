# Twitter Stream

![Firehose](https://thumbs.gfycat.com/CarefulOrderlyKarakul-max-1mb.gif)

Just a fault-tolerant Elixir Twitter Streaming Library.

## Why use Twitter Stream?

If you're looking for an unassuming twitter stream process to add to your supervision tree then `:twitter_stream` might be the one. Twitter Stream is a GenServer that establishes an HTTP connection to the Twitter API, receives and decodes chunks, then sends a tweet message to the process of your choice. This architecture allows for multiple fault-tolerant streams that send tweets to one or more processes.

## Installation

Add `:twitter_stream` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:twitter_stream, "~> 0.2"}]
end
```

For OAuth1.0 authentication, add your app's `access_token`, `token_secret`,`consumer_key`, `consumer_secret` to your environment.

```elixir
TWITTER_ACCESS_TOKEN="access_token"
TWITTER_TOKEN_SECRET="token_secret"
TWITTER_CONSUMER_KEY="consumer_key"
TWITTER_CONSUMER_SECRET="consumer_secret"
```
