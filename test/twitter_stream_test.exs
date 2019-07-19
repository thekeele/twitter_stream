defmodule HttpMock do
  def post(_, _, _, _) do
    {:ok, make_ref()}
  end
end

defmodule TwitterStreamTest do
  use ExUnit.Case

  setup do
    System.put_env("TWITTER_CONSUMER_SECRET", "consumer_secret")
    System.put_env("TWITTER_TOKEN_SECRET", "token_secret")
    System.put_env("TWITTER_CONSUMER_KEY", "consumer_key")
    System.put_env("TWITTER_ACCESS_TOKEN", "access_token")

    [name: TwitterStreamTest, params: %{"track" => "elixir"}, sink: self()]
  end

  test "receiving and decoding a valid json chunk", opts do
    {:ok, _} = TwitterStream.start_link(opts)

    send(TwitterStreamTest, {:hackney_response, make_ref(), {:status, 200, "OK"}})
    send(TwitterStreamTest, {:hackney_response, make_ref(), {:headers, []}})
    send(TwitterStreamTest, {:hackney_response, make_ref(), "{\"id\":1337}"})
    send(TwitterStreamTest, {:hackney_response, make_ref(), "{}"})

    assert_receive {:tweet, tweet}
    assert Map.has_key?(tweet, "id")
  end

  test "receiving a bad chunk", opts do
    {:ok, _} = TwitterStream.start_link(opts)
    send(TwitterStreamTest, {:hackney_response, make_ref(), ""})

    refute_receive {:tweet, _}
  end

  test "receiving a 420 response", opts do
    {:ok, _} = TwitterStream.start_link(opts)
    send(TwitterStreamTest, {:hackney_response, make_ref(), {:status, 420, ""}})

    refute_receive {:tweet, _}
  end
end
