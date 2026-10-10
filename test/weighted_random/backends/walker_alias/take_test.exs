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

        sample_size = 10_000
        opts = [backend: Mod]
        wr = WeightedRandom.preprocess_p(probabilities, opts)
        results = WeightedRandom.take(wr, sample_size)

        assert Analysis.match_probability?(probabilities, results)

      end
    end
  end

  property "Tables without :bucket_tuple (built before it existed) still work" do
    # A struct from 1.0.1 lacks the keys entirely; a partially rebuilt one may have them as nil.
    # This mostly affects 1.0.1 tables restored with :erlang.binary_to_term/1 (e.g. from ETS, persistent_term,
    # or disk) or kept by a long-running process across an upgrade, and anyone who used Map.from_struct/1 on one.
    strip_tuple = StreamData.member_of([
      &Map.drop(&1, [:bucket_tuple, :size]),
      &%{&1 | bucket_tuple: nil, size: nil}
    ])

    check all tolerance <- StreamData.float(min: 1.0e-10, max: 1.0e-5),
              floats <- StreamData.list_of(StreamData.float(min: 1.0e-4, max: 1.0), min_length: 1),
              strip <- strip_tuple do
      opts = [tolerance: tolerance]
      probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats, opts)

      sample_size = 10_000
      %{table: table} = WeightedRandom.preprocess_p(probabilities, backend: Mod)
      results = Mod.take(strip.(table), sample_size)

      assert Enum.all?(results, &(&1 in 0..(length(probabilities) - 1)))
      assert Analysis.match_probability?(probabilities, results)
    end
  end

  # Builds more buckets than fit in a tuple, using about 1GB of memory.
  # Excluded by default in test_helper.exs. Run with `mix test --include large_memory`.
  @tag :large_memory
  test "Tables too large for a tuple still work" do
    n = WeightedRandom.Backend.max_tuple_size() + 1
    table = %WeightedRandom.Backend.WalkerAlias.Table{buckets: for(i <- 0..(n - 1), do: {1.0, i, i})}

    assert Enum.all?(Mod.take(table, 10), &(&1 in 0..(n - 1)))
  end


end
