defmodule TwitterStream do
  use GenServer

  require Logger

  alias TwitterStream.Auth
  alias TwitterStream.Decoder

  @stream_url "https://stream.twitter.com/1.1/statuses/filter.json"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(%{params: params, source: source}) do
    url = @stream_url
    headers = ["Authorization": Auth.oauth_header(:post, url, params)]
    params = Map.to_list(params)
    opts = [
      {:async, :once}, {:stream_to, __MODULE__},
      {:recv_timeout, :timer.minutes(3)}
    ]

    case :hackney.post(url, headers, {:form, params}, opts) do
      {:ok, _ref} -> {:ok, %{source: source}}
      error -> {:stop, error}
    end
  end

  def init(_), do: {:stop, "options missing"}

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
      if Decoder.json?(chunk) do
        case Decoder.decode(chunk, state) do
          {:incomplete, decoder} ->
            Map.put(state, :decoder, decoder)
          %{"id" => _} = tweet ->
            send(state.source, {:tweet, tweet})
            Map.delete(state, :decoder)
        end
      else
        Map.delete(state, :decoder)
      end

    :ok = :hackney.stream_next(ref)

    {:noreply, state}
  end
end
