defmodule TwitterStream do
  @moduledoc """
  The TwitterStream API goes here...
  """

  defdelegate take_tweet(), to: __MODULE__.TweetStore
end
