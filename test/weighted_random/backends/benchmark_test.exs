defmodule WeightedRandom.Backends.BenchmarkTest do
  @moduledoc """
  Compares the backends with Benchee. Excluded by default; run with:

      mix test --only benchmark

  To include a new backend, add it to `@backends`. Every benchmark runs once per backend and per size in `@sizes`.
  """
  use ExUnit.Case
  alias WeightedRandom.Backend.{WalkerAlias, Linear}

  @moduletag :benchmark
  @moduletag timeout: :infinity

  # Add new backends here. The key is the label shown in Benchee's output.
  @backends [walker_alias: WalkerAlias, linear: Linear]

  # The number of outcomes in each scenario.
  @sizes [10, 1_000, 100_000]

  # How many values each sampling benchmark takes.
  @take_count 1_000

  @benchee_opts [warmup: 0.5, time: 2]


  describe "Compare backends" do
    test "preprocess/3: building the table", %{test: title} do
      run(
        title,
        fn backend -> fn size -> preprocess(backend, size) end end,
        memory_time: 0.5
      )
    end

    test "take/2: sampling #{@take_count} values from a prebuilt table", %{test: title} do
      run(title, fn backend ->
        {fn table -> WeightedRandom.take(table, @take_count) end,
         before_scenario: fn size -> preprocess(backend, size) end}
      end)
    end

    test "rand/3: preprocessing and sampling 10 values in one call", %{test: title} do
      run(title, fn backend ->
        fn size -> WeightedRandom.rand(outcomes(size), weights(size), backend: backend, take: 10) end
      end)
    end
  end

  describe "Utilities" do
    test "reseed" do
      Benchee.run(%{"reseed" => fn -> WeightedRandom.Utils.Crypto.reseed() end}, @benchee_opts)
    end
  end


  # Builds one Benchee job per backend from `job_for_backend`, and runs each job against every size.
  defp run(title, job_for_backend, opts \\ []) do
    jobs = Map.new(@backends, fn {name, backend} -> {to_string(name), job_for_backend.(backend)} end)
    inputs = Enum.map(@sizes, fn size -> {"#{size} outcomes", size} end)
    Benchee.run(jobs, @benchee_opts ++ [title: title |> to_string() |> String.replace_prefix("test ", ""), inputs: inputs] ++ opts)
  end

  defp preprocess(backend, size) do
    WeightedRandom.preprocess(outcomes(size), weights(size), backend: backend)
  end

  defp outcomes(size), do: 0..(size - 1)

  # One outcome is as likely as all the others combined, so every backend gets a skewed distribution.
  defp weights(size), do: [%{target: div(size, 2), amount: size}]
end
