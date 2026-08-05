defmodule WeightedRandom.Backends.BenchmarkTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.WalkerAlias, as: Wam
  alias WeightedRandom.Backend.Linear
  alias WeightedRandom.Backend.ThreeFry

  @opts []
  def repeat(cb, count) do
    for n <- 1..count do
      cb.(n)
    end
  end

  describe "Benchmark the various backends" do
    @tag timeout: :infinity, skip: true
    test "Preprocessing speed, n iterations" do
      weights = [%{target: 50, weight: 50, radius: 15}]
      range = 1..100
      count = 1_000_000

      bench = Benchee.run(
        %{
          "preprocess_linear_#{count}" => fn -> repeat(fn _ -> WeightedRandom.preprocess(range, weights, backend: Linear) end, count) end,
          "preprocess_walker_alias_#{count}" => fn -> repeat(fn _ -> WeightedRandom.preprocess(range, weights, backend: Wam) end, count) end,
          "preprocess_three_fry_#{count}" => fn -> repeat(fn _ -> WeightedRandom.preprocess(range, weights, backend: ThreeFry) end, count) end,
        }, @opts)
    end

    @tag timeout: :infinity, skip: true
    test "sampling speed, n iteration" do
      weights = [%{target: 50, weight: 50, radius: 15}]
      range = 1..100
      count = 100
      linear_table = WeightedRandom.preprocess(range, weights, backend: Linear)
      wam_table = WeightedRandom.preprocess(range, weights, backend: Wam)
      three_fry_table = WeightedRandom.preprocess(range, weights, backend: ThreeFry)

      bench = Benchee.run(
        %{
          "take_linear_#{count}" => fn -> repeat(fn _acc -> WeightedRandom.take(linear_table, count, backend: Linear) end, count) end,
          "take_walker_alias_#{count}" => fn -> repeat(fn _acc -> WeightedRandom.take(wam_table, count, backend: Wam) end, count) end,
          "take_three_fry_#{count}" => fn -> repeat(fn acc -> WeightedRandom.take(three_fry_table, count, backend: ThreeFry, key: acc) end, count) end,
        }, @opts)
    end

    @tag timeout: :infinity, skip: true
    test "`rand` function, n iterations " do
      weights = [%{target: 50, weight: 50, radius: 15}]
      range = 1..100
      count = 1000
      linear_table = WeightedRandom.preprocess(range, weights, backend: Linear)
      wam_table = WeightedRandom.preprocess(range, weights, backend: Wam)
      three_fry_table = WeightedRandom.preprocess(range, weights, backend: ThreeFry)

      bench = Benchee.run(
        %{
          "rand_linear_#{count}" => fn -> repeat(fn _acc -> WeightedRandom.rand(range, weights, take: count, backend: Linear) end, count) end,
          "rand_walker_alias_#{count}" => fn -> repeat(fn _acc -> WeightedRandom.rand(range, weights, take: count, backend: Wam) end, count) end,
          "rand_three_fry_#{count}" => fn -> repeat(fn acc -> WeightedRandom.rand(range, weights, take: count, backend: ThreeFry, key: acc) end, count) end,
        }, @opts)
    end

  end
end
