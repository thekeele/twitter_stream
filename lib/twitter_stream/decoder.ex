defmodule TwitterStream.Decoder do

  def decode_chunk(chunk, %{decoder: decoder}) do
    try do
      decoder.(:end_stream)
    rescue
      _error in ArgumentError -> decoder.(chunk)
    end
  end

  def decode_chunk(chunk, _) do
    try do
      :jsx.decode(chunk, [:stream, :return_maps])
    rescue
      _error in ArgumentError -> :bad_chunk
    end
  end
end
