use Mix.Config

config :twitter_stream, http: :hackney

import_config "#{Mix.env()}.exs"
