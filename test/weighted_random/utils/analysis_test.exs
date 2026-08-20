defmodule WeightedRandom.Utils.AnalysisTest do
  use ExUnit.Case
  alias WeightedRandom.Utils.Analysis, as: Mod
  import Mod
  doctest Mod

  describe "Analysis" do

    test "get probabilities" do
      li = List.duplicate(1, 25) ++ List.duplicate(0, 75)
      assert Mod.get_probabilities_from_results(li) == %{0 => 0.75, 1 => 0.25}
    end

    test "get delta" do
      li = List.duplicate(1, 25) ++ List.duplicate(0, 75)
      probs = [0.75, 0.25]
      assert Mod.get_delta(probs, li) == [0.0, 0.0]
    end

    test "match probabilities" do
      li = List.duplicate(1, 25) ++ List.duplicate(0, 75)
      probs = [0.75, 0.25]
      assert Mod.match_probability?(probs, li)
    end

    test "from weights" do
      p = Mod.get_probabilities_from_weights(1..10, [%{target: 3, weight: 2}])
      assert Mod.sum_delta(p, 1.0) == 0.0
    end

    test "integration" do
      probabilities = [0.1, 0.1, 0.1, 0.7]
      results = WeightedRandom.rand_p(probabilities, [take: 100])
      assert Mod.match_probability?(probabilities, results, 0.15)
    end
  end

end
