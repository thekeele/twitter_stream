defmodule TwitterStream do
  @moduledoc """
  TwitterStream is a GenServer that can be invoked manually via `start_link/1` or
  added as a `child_spec/1` to a supervision tree.
  """
  use GenServer

  alias TwitterStream.{Auth, Decoder}

  @doc """
  Start a twitter stream process given [Twitter Streaming API](https://developer.twitter.com/en/docs/tweets/filter-realtime/api-reference/post-statuses-filter) parameters and a process to sink tweets to.

  Returns `{:ok, pid}`.

  ## The available keyword list of options are:

  Parameters to send to the [Twitter Streaming API](https://developer.twitter.com/en/docs/tweets/filter-realtime/api-reference/post-statuses-filter).
  ```elixir
  params: %{"track" => "developer", "language" => "en", "filter_level" => "low"}
  ```

  Process to send all decoded tweets to.
  ```elixir
  sink: self()
  ```

  GenServer registration name, optional and defaults to `TwitterStream`.
  ```elixir
  name: DeveloperTwitterStream
  ```

  ## Examples

      iex> opts = [params: %{"track" => "developer"}, sink: self()]
      iex> {:ok, pid} = TwitterStream.start_link(opts)
      iex> flush()
      {:tweet,
        %{
          "text" => "...",
          ...
        }
      }

  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc false
  def init(opts) do
    http = Application.get_env(:twitter_stream, :http) || :hackney
    url = "https://stream.twitter.com/1.1/statuses/filter.json"
    headers = ["Authorization": Auth.oauth_header("post", url, opts[:params])]
    params = Map.to_list(opts[:params])
    stream_opts = [
      {:async, :once}, {:stream_to, self()},
      {:recv_timeout, :timer.minutes(3)}
    ]

    case http.post(url, headers, {:form, params}, stream_opts) do
      {:ok, _ref} -> {:ok, %{sink: opts[:sink]}}
      error -> {:stop, error}
    end
  end

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, state) do
    :hackney.stream_next(ref)

    {:noreply, state}
  end

  def handle_info({:hackney_response, ref, {:status, 420, _}}, _state) do
    :hackney.close(ref)

    {:stop, :normal, %{}}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, state) do
    :hackney.stream_next(ref)

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

    :hackney.stream_next(ref)

    {:noreply, state}
  end
end
