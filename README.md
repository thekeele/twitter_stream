# TwitterStream

Just a fault-tolerant Twitter Streaming Elixir Application.

```
%{
  params: %{
    "track" => "bitcoin",
    "language" => "en",
    "filter_level" => "none"
  },
  sink: self()
}
```
