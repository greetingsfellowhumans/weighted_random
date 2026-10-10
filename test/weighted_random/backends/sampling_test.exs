defmodule WeightedRandom.Backends.SamplingTest do
  # Checks that apply to every built-in backend's `take/2`, for both of its paths:
  # a single value is sampled with `:rand`, and more than one with `:rand.mwc59/1`.
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias WeightedRandom.Backend.{WalkerAlias, Linear}
  alias WeightedRandom.Utils.Analysis

  @backends [WalkerAlias, Linear]

  property "Should take values with the correct probabilities" do
    check all tolerance <- StreamData.float(min: 1.0e-10, max: 1.0e-5),
              floats <- StreamData.list_of(StreamData.float(min: 1.0e-4, max: 1.0), min_length: 1),
              backend <- StreamData.member_of(@backends) do
      probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats, tolerance: tolerance)

      sample_size = 10_000
      results = WeightedRandom.rand_p(probabilities, backend: backend, take: sample_size)

      assert length(results) == sample_size
      assert Analysis.match_probability?(probabilities, results)
    end
  end

  test "Single values have the correct probabilities" do
    probabilities = [0.5, 0.3, 0.2]

    for backend <- @backends do
      r = WeightedRandom.preprocess_p(probabilities, backend: backend)
      results = for _ <- 1..20_000, do: WeightedRandom.take(r)
      assert Analysis.match_probability?(probabilities, results, 0.02)
    end
  end

  test ":rand.seed/1 makes the results reproducible" do
    for backend <- @backends, count <- [1, 100] do
      r = WeightedRandom.preprocess(1..100, [%{target: 50, amount: 100}], backend: backend)

      :rand.seed(:exsss, {1, 2, 3})
      first = WeightedRandom.take(r, count)
      :rand.seed(:exsss, {1, 2, 3})
      assert WeightedRandom.take(r, count) == first
    end
  end

  test "Seeded single values match 1.0.1" do
    # 1.0.1's `take/2` for each backend, so seeded results sampled one at a time keep working across upgrades.
    walker_alias_1_0_1 = fn table ->
      coin_flip = :rand.uniform()
      case Enum.random(table.buckets) do
        {split_point, _lower, higher} when split_point < coin_flip -> higher
        {split_point, lower, _higher} when split_point >= coin_flip -> lower
      end
    end
    linear_1_0_1 = fn table ->
      point = :rand.uniform() * table.total
      Enum.find_index(table.cumulative, &(point < &1))
    end

    for {backend, take_1_0_1} <- [{WalkerAlias, walker_alias_1_0_1}, {Linear, linear_1_0_1}], seed <- 1..20 do
      r = WeightedRandom.preprocess(1..20, [%{target: 5, amount: 10}], backend: backend)

      :rand.seed(:exsss, {seed, 2, 3})
      expected = for _ <- 1..50, do: take_1_0_1.(r.table)
      :rand.seed(:exsss, {seed, 2, 3})
      assert (for _ <- 1..50, do: backend.take(r.table, 1)) == Enum.map(expected, &[&1])
    end
  end

  test "Every index can be picked" do
    for backend <- @backends do
      results = WeightedRandom.rand_p(List.duplicate(0.1, 10), backend: backend, take: 10_000)
      assert results |> Enum.uniq() |> Enum.sort() == Enum.to_list(0..9)
    end
  end
end
