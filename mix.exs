defmodule WeightedRandom.MixProject do
  use Mix.Project

  def project do
    [
      app: :weighted_random,
      version: "1.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/aaron-price/weighted_random"
    ]
  end

  defp description() do
    "Helper functions for working with weighted random values."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Aaron Price"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/aaron-price/weighted_random"}
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
        {:ex_doc, "~> 0.16", only: :dev, runtime: false},
        {:mix_test_watch, "~> 1.2", only: [:dev, :test], runtime: false},
    ]
  end
end
