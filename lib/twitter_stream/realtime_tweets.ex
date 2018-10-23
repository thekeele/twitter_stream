defmodule TwitterStream.RealtimeTweets do
  use GenServer

  alias TwitterStream.OAuthOne, as: Auth

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(params) do
    url = "https://stream.twitter.com/1.1/statuses/filter.json"
    headers = ["Authorization": Auth.oauth_header(:post, url, params)]
    params = Map.to_list(params)
    opts = [
      {:async, :once}, {:stream_to, __MODULE__},
      {:connect_timeout, 60 * 1000},
      {:recv_timeout, 60 * 1000}
    ]

    case :hackney.post(url, headers, {:form, params}, opts) do
      {:ok, _ref} -> {:ok, %{}}
      error -> {:stop, error}
    end
  end

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end

  def handle_info({:hackney_response, ref, chunk}, state) when is_binary(chunk) do
    state =
      chunk
      |> decode_chunk(state)
      |> put_decoded_state(state)

    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end

  defp decode_chunk(chunk, %{decoder: decoder}) do
    try do
      decoder.(:end_stream)
    rescue
      _error in ArgumentError -> decoder.(chunk)
    end
  end

  defp decode_chunk(chunk, _state) do
    try do
      :jsx.decode(chunk, [:stream, :return_maps])
    rescue
      _error in ArgumentError -> :bad_chunk
    end
  end

  defp put_decoded_state({:incomplete, decoder}, state) do
    Map.put(state, :decoder, decoder)
  end

  defp put_decoded_state(tweet, state) when is_map(tweet) do
    :ets.insert(:tweet_store, {tweet["id"], tweet})

    Map.delete(state, :decoder)
  end

  defp put_decoded_state(_unhandled, state) do
    state
  end
end
