defmodule WeightedRandom.MixProject do
  use Mix.Project

  def project do
    [
      app: :weighted_random,
      version: "1.0.0-alpha.2",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs() do
    [
      main: "1_quickstart-1",
      groups_for_modules: [
        "Backend": ~r"WeightedRandom.Backend",
        "Dice": [WeightedRandom.Dice, WeightedRandom.Die],
        "Utils": [WeightedRandom.Utils],
      ],
      nest_modules_by_prefix: [
        WeightedRandom.Backend,
        WeightedRandom.Dice,
        WeightedRandom.Utils,
      ],
      groups_for_extras: [
        "Static Tutorial": Path.wildcard("guides/static/*.md"),
        "Livebook Tutorial": Path.wildcard("guides/live/*.livemd"),
      ],
      extras: [
        "CHANGELOG.md",
        "README.md",
      ] ++ Path.wildcard("guides/static/*.md")
        ++ Path.wildcard("guides/live/*.livemd"),
      skip_undefined_reference_warnings_on: ["CHANGELOG.md", "README.md"]
    ]
  end


  defp description() do
    "Fast and flexible framework for simulating weighted randomness with custom probabilities and bias."
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
      {:curves, "~> 0.2.4"},
      {:nimble_options, "~> 1.0"},
      {:benchee, "~> 1.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:vega_lite, "~> 0.1.0", only: :dev, runtime: false},
      {:kino_vega_lite, "~> 0.1.0", only: :dev, runtime: false},
      {:stream_data, "~> 1.0", only: :test},
      {:mix_test_interactive, "~> 5.1", only: [:dev, :test], runtime: false}
    ]
  end
end
