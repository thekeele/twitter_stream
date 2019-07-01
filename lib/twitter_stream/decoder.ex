defmodule TwitterStream.Decoder do
  @moduledoc false

  def json?(chunk) do
    try do
      :jsx.is_json(chunk)
    catch
      :initialdecimal -> false
    end
  end

  def decode(chunk, %{decoder: decoder}) do
    try do
      decoder.(:end_stream)
    catch
      :error, :badarg -> decoder.(chunk)
    end
  end

  def decode(chunk, _) do
    :jsx.decode(chunk, [:stream, :return_maps])
  end
end
