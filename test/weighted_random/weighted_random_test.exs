defmodule WeightedRandom.WeightedRandomTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.{WalkerAlias, Linear}
  alias WeightedRandom, as: Mod
  alias Mod.Utils.Analysis

  @opts []

  describe "rand/3" do
    @tag skip: "come back when you fix analysis for outcomes."
    test "No weights" do
      outcomes = 1..6
      weights = []
      li = Mod.rand(1..6, [], [take: 100, index: false])
      probs = Analysis.get_probabilities_from_weights(outcomes, weights)
      assert Enum.count(li) == 100
      assert Enum.all?(li, &is_integer/1)
      assert Enum.all?(li, &(&1 >= 1))
      assert Enum.all?(li, &(&1 <= 6))

      Analysis.match_probability?(probs, li)
    end
    test "simple weight" do
      li = Mod.rand(1..6, [%{target: 3, amount: 10}], [take: 100])
      assert Enum.count(li) == 100
      assert Enum.all?(li, &is_integer/1)
      assert Enum.all?(li, &(&1 >= 1))
      assert Enum.all?(li, &(&1 <= 6))
    end
  end

  describe "rand_p/2" do
    test "No weights" do
      probabilities = [0.1, 0.1, 0.1, 0.7]
      li = Mod.rand_p(probabilities, [take: 10000])
      assert Analysis.match_probability?(probabilities, li)
    end
  end

end
