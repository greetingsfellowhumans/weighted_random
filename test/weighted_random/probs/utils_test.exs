defmodule WeightedRandom.Probs.UtilsTest do
  use ExUnit.Case
  alias WeightedRandom.Probs.Utils, as: Mod
  alias WeightedRandom.Utils.Analysis
  import Analysis, only: [equalish?: 2, sum_equalish?: 2]
  import Mod

  describe "Probs.Utils" do
    test "coerce any list of positive numbers into a list of floats that sum to 1.0" do
      li = [1, 1, 1, 1]
      expected = [0.25, 0.25, 0.25, 0.25]
      assert equalish?(nums_to_probabilities(li), expected)
      assert sum_equalish?(expected, 1.0)

      li = [1, 1, 1]
      expected = [0.333, 0.333, 0.333]
      assert equalish?(nums_to_probabilities(li), expected)
      assert sum_equalish?(expected, 1.0)

      li = [1, 1, 8]
      expected = [0.1, 0.1, 0.8]
      assert equalish?(nums_to_probabilities(li), expected)
      assert sum_equalish?(expected, 1.0)

      li = [0.1, 0.1, 0.8]
      expected = [0.1, 0.1, 0.8]
      assert equalish?(nums_to_probabilities(li), expected)
      assert sum_equalish?(expected, 1.0)

      li = [0.7, 0.1]
      expected = [0.875, 0.125]
      assert equalish?(nums_to_probabilities(li), expected)
      assert sum_equalish?(expected, 1.0)
    end
  end

end

