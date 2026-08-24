defmodule WeightedRandom.Backends.BenchmarkTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.{WalkerAlias, Linear}

  @opts []

  describe "Benchmark the various backends" do
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
          "runtime_list_10" => fn -> WeightedRandom.rand(1..100, [%{target: 50, weight: 50, radius: 15}], [backend: WalkerAlias, take: 10]) end,
          "walker_alias_10" => fn -> WeightedRandom.rand(1..100, [%{target: 50, weight: 50, radius: 15}], [backend: Linear, take: 10]) end,
        }, @opts)
      dbg bench
    end


    @tag skip: "This does not need to run every time."
    test "Sample size 1_000_000" do
      bench = Benchee.run(
        %{
          "runtime_list_1M" => fn -> WeightedRandom.rand(1..100, [%{target: 50, weight: 50, radius: 15}], [backend: WalkerAlias, take: 1_000_000]) end,
          "walker_alias_1M" => fn -> WeightedRandom.rand(1..100, [%{target: 50, weight: 50, radius: 15}], [backend: Linear, take: 1_000_000]) end,
        }, @opts)
      dbg bench
    end
  end

end
