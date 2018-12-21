defmodule TwitterStream.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :twitter_stream,
      version: @version,
      elixir: "~> 1.7",
      package: package(),
      description: "Just a fault-tolerant Elixir Twitter Streaming Library.",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "TwitterStream",
        source_ref: "v#{@version}",
        source_url: "https://github.com/thekeele/twitter_stream"
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:hackney, "~> 1.14.3"},
      {:jsx, "~> 2.9"},
    ]
  end

  defp package do
    %{
      licenses: [],
      maintainers: ["Mark Keele"],
      links: %{"GitHub" => "https://github.com/thekeele/twitter_stream"}
    }
  end
end
