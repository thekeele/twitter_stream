defmodule TwitterStream.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitter_stream,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {TwitterStream.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:hackney, "~> 1.14.3"},
      {:jsx, "~> 2.9"},
    ]
  end
end
