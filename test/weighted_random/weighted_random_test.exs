defmodule WeightedRandom.WeightedRandomTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.{WalkerAlias, Linear}
  alias WeightedRandom, as: Mod
  alias Mod.Utils.Analysis

  @opts []

  describe "rand/3" do
    test "No weights" do
      li = Mod.rand(1..6, [], [take: 100])
      assert Enum.count(li) == 100
      assert Enum.all?(li, &is_integer/1)
      assert Enum.all?(li, &(&1 >= 1))
      assert Enum.all?(li, &(&1 <= 6))
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
      num_probs = Enum.count(probabilities)

      li = Mod.rand_p(probabilities, [take: 10000])
      assert Analysis.match_probability?(probabilities, li)

    end
  end

end
