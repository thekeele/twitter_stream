defmodule TwitterStream.MixProject do
  use Mix.Project

  @version "0.2.2"

  def project() do
    [
      app: :twitter_stream,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
      ],
      docs: [
        main: "TwitterStream",
        source_ref: "v#{@version}",
        source_url: "https://github.com/thekeele/twitter_stream"
      ]
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp deps() do
    [
      {:hackney, "~> 1.14.3"},
      {:jsx, "~> 2.9"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp description() do
    "Just a fault-tolerant Elixir Twitter Streaming Library."
  end

  defp package() do
    %{
      licenses: ["MIT"],
      maintainers: ["Mark Keele"],
      links: %{"GitHub" => "https://github.com/thekeele/twitter_stream"}
    }
  end
end
