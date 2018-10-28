defmodule TwitterStream.TweetStore do
  use GenServer

  @tab :tweet_store

  def start_link() do
    GenServer.start_link(__MODULE__, @tab, name: __MODULE__)
  end

  def insert(tweet) do
    GenServer.call(__MODULE__, {:insert, tweet})
  end

  def take_tweet() do
    GenServer.call(__MODULE__, :take_first_tweet)
  end

  def init(tab) do
    opts = [
      :set,
      :protected,
      :named_table,
      {:write_concurrency, false},
      {:read_concurrency, false}
    ]

    {:ok, :ets.new(tab, opts)}
  end

  def handle_call({:insert, tweet}, _from, state) do
    :ets.insert(@tab, {tweet["id"], tweet})

    {:reply, :ok, state}
  end

  def handle_call(:take_first_tweet, _from, state) do
    :ets.safe_fixtable(@tab, true)
    tweet = take_first_tweet()
    :ets.safe_fixtable(@tab, false)

    {:reply, tweet, state}
  end

  defp take_first_tweet() do
    case :ets.first(@tab) do
      tweet_id when is_integer(tweet_id) -> :ets.take(@tab, tweet_id)
      _end_of_table -> []
    end
  end
end
