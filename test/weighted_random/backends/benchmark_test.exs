defmodule WeightedRandom.Backends.BenchmarkTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.{WalkerAlias}

  @opts []
  @backends [walker_alias: WalkerAlias]
  @outcomes 1..10_000
  @weight1 %{target: 50, weight: 50, radius: 15}
  @weight2 %{target: 20, weight: 50, radius: 15}
  @weight3 %{target: 800, weight: 50, radius: 15}
  @weights [@weight1, @weight2, @weight3]


  def benchmark_take(take) do
    Enum.reduce(@backends, %{}, fn {k, mod}, acc ->
      table = WeightedRandom.preprocess(@outcomes, @weights, [backend: mod])
      Map.put(acc, "#{k}_take_#{take}", fn -> WeightedRandom.take(table, take) end)
    end)
  end

  describe "Benchmark the various backends" do
    @tag :skip
    test "sampling speed benchmarks" do
      elements = Enum.map(1..100, fn _i -> :rand.uniform() end)
      table = WeightedRandom.preprocess_p(elements)
      bench = Benchee.run(
        %{
          "10k random probabilities" => fn -> WeightedRandom.take(table, 100) end
        }
      )
    end

    @tag :skip
    test "reseed" do
      bench = Benchee.run(
        %{
          "reseed_10" => fn -> WeightedRandom.Utils.Crypto.reseed() end
        }, @opts)
      dbg bench
    end

    @tag skip: "This does not need to run every time."
    test "Sample size 10" do
      bench = Benchee.run(
        %{
          "runtime_list_10" => fn -> WeightedRandom.rand(1..100, @weights, [backend: WalkerAlias, take: 10]) end,
          "walker_alias_10" => fn -> WeightedRandom.rand(1..100, @weights, [backend: Linear, take: 10]) end,
        }, @opts)
      dbg bench
    end


    @tag :skip
    test "Sample size 1_000_000" do
      bench = Benchee.run(
        %{
          "wam_1M" => fn -> WeightedRandom.rand(1..100, [%{target: 50, weight: 50, radius: 15, curve: :ease_in_out}], [backend: WalkerAlias, take: 1_000_000]) end,
        }, @opts)
      dbg bench
    end
  end

end
