defmodule WeightedRandom.Backends.Walker.TakeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias WeightedRandom.Backend.WalkerAlias, as: Mod
  alias WeightedRandom.Utils.Analysis

  describe "Property tests for Take" do
    property "Should take values with the correct probabilities" do
      check all tolerance <- StreamData.float(min: 1.0e-10, max: 1.0e-5),
                floats <- StreamData.list_of(StreamData.float(min: 1.0e-4, max: 1.0), min_length: 1) do
        opts = [tolerance: tolerance]
        probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats, opts)

        sample_size = 1000
        opts = [backend: Mod]
        wr = WeightedRandom.preprocess_p(probabilities, opts)
        results = WeightedRandom.take(wr, sample_size)
        #outcomes = Enum.with_index(probabilities)
        #          |> Enum.map(fn {_, i} -> i end)
        assert Analysis.match_probability?(probabilities, results, 0.1)

      end
    end
  end


end
