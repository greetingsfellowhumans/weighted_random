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

        assert Analysis.match_probability?(probabilities, results)

      end
    end
  end

  test "Tables without :bucket_tuple (built before it existed) still work" do
    probabilities = [0.1, 0.2, 0.3, 0.4]
    %{table: table} = WeightedRandom.preprocess_p(probabilities, backend: Mod)
    old_table = %{table | bucket_tuple: nil, size: nil}

    results = Mod.take(old_table, 10_000)
    assert Enum.all?(results, &(&1 in 0..3))
    assert Analysis.match_probability?(probabilities, results)
  end


end
