defmodule WeightedRandom.ProbabilityTest do
  use ExUnit.Case
  alias WeightedRandom.Probability, as: Mod
  alias WeightedRandom.Weight

  describe "Probability" do
    test "get_probabilities/3" do
      outcomes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      weights = [WeightedRandom.Weight.new(%{target: 6, weight: 10})] |> Weight.expand_weights()
      opts = []

      p = WeightedRandom.get_probabilities(outcomes, weights, opts)
      assert p == [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.55, 0.05, 0.05, 0.05]
      assert Float.round(Enum.sum(p), 5) == 1.0

      weights = [WeightedRandom.Weight.new(%{target: 1, weight: 2.75})] |> Weight.expand_weights()
      p = WeightedRandom.get_probabilities(outcomes, weights, opts)
      assert Float.round(Enum.sum(p), 5) == 1.0

      weights = [Weight.new(%{target: 15, weight: 100.234, radius: 10})] |> Weight.expand_weights()
      tws = Enum.map(weights, &({&1.target, &1.total_weight}))
      [{6, n} | _] = tws
      assert Float.round(n, 5) == Float.round(100.234 / 10, 5)
      assert Float.round(100.234 * 10, 3) == 1002.34
      assert Float.round(Mod.sum_weights(weights), 5) == 1002.34

      outcomes = 1..10
      weights = [WeightedRandom.Weight.new(%{target: 5, weight: 2.75, radius: 3})] |> Weight.expand_weights()
      p = WeightedRandom.get_probabilities(outcomes, weights, opts)
      [t0, _t1, t2, _t3, t4, t5, _t6 | _] = p
      assert t0 == t2
      assert t5 > t4

      weights = [
        WeightedRandom.Weight.new(%{target: 5, weight: 1, radius: 1}),
        WeightedRandom.Weight.new(%{target: 5, weight: 1, radius: 1}),
        WeightedRandom.Weight.new(%{target: 5, weight: 1, radius: 1}),
        WeightedRandom.Weight.new(%{target: 5, weight: 1, radius: 1}),
        WeightedRandom.Weight.new(%{target: 5, weight: 1, radius: 1}),
      ] |> Weight.expand_weights()
      p = WeightedRandom.get_probabilities(outcomes, weights, opts)
      [t0, t1, _t2, _t3, _t4, t5, t6 | _] = p
      assert t0 == t1
      assert t0 < t5
      assert t6 < t5
      assert Float.round(t0, 3) == 0.067
      assert Float.round(t5, 3) == 0.4

      p = WeightedRandom.get_probabilities(outcomes, weights, [probability_type: :fraction])
      [{1, 15}, {1, 15}, _t2, _t3, _t4, {6, 15}, {1, 15} | _] = p
    end

    test "sum_weights/1" do
      weights = [Weight.new(%{target: 6, weight: 10})] |> Weight.expand_weights()
      tot = Mod.sum_weights(weights)
      assert tot == 10

      weights = [Weight.new(%{target: 6, weight: 10, radius: 3})] |> Weight.expand_weights()
      tot = Mod.sum_weights(weights)
      assert tot == 30
    end

    test "get_equal_share/2" do
      outcomes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      weights = [Weight.new(%{target: 6, weight: 10})] |> Weight.expand_weights()
      count = Enum.count(outcomes)
      tot = Mod.get_equal_share(count, weights)
      assert tot == 0.05
    end
  end
end
