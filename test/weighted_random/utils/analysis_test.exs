defmodule WeightedRandom.Utils.AnalysisTest do
  use ExUnit.Case
  alias WeightedRandom.Utils.Analysis, as: Mod
  import Mod
  doctest Mod

  describe "Analysis" do

    test "get probabilities" do
      li = List.duplicate(1, 25) ++ List.duplicate(0, 75)
        |> Enum.shuffle()
      assert Mod.get_probabilities_from_results(li, [0, 1]) == [0.75, 0.25]
    end

    @tag skip: "Come back once you clean up options"
    test "get delta" do
      # With index
      li = List.duplicate(1, 25) ++ List.duplicate(0, 75)
      probs = [0.75, 0.25]
      assert Mod.get_delta(probs, li) == [0.0, 0.0]


      # With values
      outcomes = 100..130//10
      expected = [0.25, 0.25, 0.25, 0.25]
      results = [100, 120, 110, 130]
      actual_freq = get_probabilities_from_results(results, outcomes)
      dbg actual_freq
      # @TODO
      # build an actual analysis domain
      # with a module to get the %{value => index} and %{value => probability} maps
      # And normalize just using those two, eliminating the need to constantly check :index
      #
      # Also rename :index to result_type: :index | :value
      #
      Mod.get_delta(expected, results)
    end

    test "match probabilities" do
      li = List.duplicate(1, 25) ++ List.duplicate(0, 75)
      probs = [0.75, 0.25]
      assert Mod.match_probability?(probs, li)
    end

    test "from weights" do
      p = Mod.get_probabilities_from_weights(1..10, [%{target: 3, weight: 2}])
      assert Mod.sum_equalish?(p, 1.0)
    end

    test "index_to_outcome_table" do
      outcomes = 100..130//10
      opts = [index: true]
      table = Mod.index_to_outcome_table(outcomes, opts)
      assert table == %{0 => 100, 1 => 110, 2 => 120, 3 => 130}


      #opts = [index: false]
      #table = Mod.index_to_outcome_table(outcomes, opts)
      #assert table == %{0 => 100, 1 => 110, 2 => 120, 3 => 130}
    end

    test "integration" do
      probabilities = [0.1, 0.1, 0.1, 0.7]
      results = WeightedRandom.rand_p(probabilities, [take: 100])
      assert Mod.match_probability?(probabilities, results, 0.15)
    end
  end

end
