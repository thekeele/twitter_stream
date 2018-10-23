defmodule TwitterStream.TweetStore do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :tweet_store, name: __MODULE__)
  end

  def init(table) do
    :ets.new(table, [:named_table, :public])

    {:ok, :ok}
  end
end
