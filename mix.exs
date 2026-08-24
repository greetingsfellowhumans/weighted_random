defmodule WeightedRandom.MixProject do
  use Mix.Project

  def project do
    [
      app: :weighted_random,
      version: "1.0.0-alpha.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      cli: cli(),
      deps: deps(),
      docs: docs(),
      source_url: "https://github.com/greetingsfellowhumans/weighted_random"
    ]
  end

  defp cli() do
    [preferred_cli_env: ["test.watch": :test]]
  end

  defp docs() do
    [
      main: "readme",
      extras: [
        "CHANGELOG.md",
        "guides/tutorial.livemd"
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end


  defp description() do
    "Fast, flexible, powerful framework for simulating weighted randomness"
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["greetingsfellowhumans"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/greetingsfellowhumans/weighted_random"}
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
      {:wam, "~> 0.1.0"},
      {:curves, "~> 0.2.3"},
      {:nimble_options, "~> 1.0"},
      {:benchee, "~> 1.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:vega_lite, "~> 0.1.0", only: :dev, runtime: false},
      {:kino_vega_lite, "~> 0.1.0", only: :dev, runtime: false},
      {:mix_test_interactive, "~> 5.1", only: [:dev, :test], runtime: false}
    ]
  end
end
