defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:maru, "~> 0.14-pre.1"},
      {:plug_cowboy, "~> 2.0"},
      {:cowlib, "2.7.0", override: true},

                                 {:poison, "~> 3.1"},
      # Optional dependency, you can also add your own json_library dependency
      # and config with `config :maru, json_library, YOUR_JSON_LIBRARY`.
      {:jason, "~> 1.1"}
    ]
  end
end
