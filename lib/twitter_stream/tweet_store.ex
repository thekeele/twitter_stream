defmodule TwitterStream.TweetStore do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :tweet_store, name: __MODULE__)
  end

  def insert(tweet) do
    GenServer.call(__MODULE__, {:insert, tweet})
  end

  def init(table) do
    opts = [
      :set,
      :protected,
      :named_table,
      {:write_concurrency, false},
      {:read_concurrency, false}
    ]

    {:ok, :ets.new(table, opts)}
  end

  def handle_call({:insert, tweet}, _from, state) do
    :ets.insert(:tweet_store, {tweet["id"], tweet})

    {:reply, :ok, state}
  end
end
