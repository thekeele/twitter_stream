defmodule TwitterStream.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(TwitterStream.TweetStore, []),
      worker(TwitterStream.RealtimeTweets, [%{"track" => "bitcoin"}]),
    ]

    opts = [strategy: :one_for_one, name: TwitterStream.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
