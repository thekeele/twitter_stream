defmodule TwitterStream do
  use GenServer

  alias TwitterStream.{Auth, Decoder}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    url = "https://stream.twitter.com/1.1/statuses/filter.json"
    headers = ["Authorization": Auth.oauth_header("post", url, opts[:params])]
    params = Map.to_list(opts[:params])
    stream_opts = [
      {:async, :once}, {:stream_to, self()},
      {:recv_timeout, :timer.minutes(3)}
    ]

    case :hackney.post(url, headers, {:form, params}, stream_opts) do
      {:ok, _ref} -> {:ok, %{sink: opts[:sink]}}
      error -> {:stop, error}
    end
  end

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end

  def handle_info({:hackney_response, ref, {:status, 420, _}}, _state) do
    :hackney.close(ref)

    {:noreply, %{}}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end

  def handle_info({:hackney_response, ref, chunk}, state) when is_binary(chunk) do
    state =
      with true <- Decoder.json?(chunk),
           %{"id" => _} = tweet <- Decoder.decode(chunk, state) do
        send(state.sink, {:tweet, tweet})
        Map.delete(state, :decoder)
      else
        false -> Map.delete(state, :decoder)
        {:incomplete, decoder} -> Map.put(state, :decoder, decoder)
      end

    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end
end
