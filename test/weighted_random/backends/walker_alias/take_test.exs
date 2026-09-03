defmodule WeightedRandom.Backends.Walker2.TakeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias WeightedRandom.Backend.WalkerAlias2, as: Mod
  alias Mod.Buckets.Sorter
  alias WeightedRandom.Utils.Analysis

  #describe "Property tests for Take" do
  #  property "take with the correct probabilities" do
  #    check all floats <- StreamData.list_of(StreamData.float(min: 0.01, max: 0.9), min_length: 1) do
  #      probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats)
  #                      |> Enum.map(&(Float.round(&1, 4)))

  #      sample_size = 100_000
  #      tolerance = 0.15
  #      opts = [backend: WeightedRandom.Backend.WalkerAlias]
  #      opts = [backend: Mod]
  #      wr = WeightedRandom.preprocess_p(probabilities, opts)
  #      results = WeightedRandom.take(wr, sample_size)
  #      if Analysis.match_probability?(probabilities, results, tolerance) do
  #        assert true
  #      else
  #        frq = Analysis.get_frequency_of_results(results)
  #        d = Analysis.get_delta(probabilities, results)
  #        dbg {probabilities, frq, d}
  #        refute true
  #      end

  #    end
  #  end
  #end


  #describe "Take" do
  #  test "ascending list" do
  #    opts = [backend: Mod]
  #    tolerance = 0.1
  #    sample_size = 100_000
  #    probs = [0.2, 0.4, 0.2, 0.2]
  #    wr = WeightedRandom.preprocess_p(probs, opts)
  #    assert wr.backend == WeightedRandom.Backend.WalkerAlias2
  #    sample = WeightedRandom.take(wr, sample_size)
  #    d1 = Analysis.get_delta(probs, sample)
  #    dbg {:custom, d1}

  #    wr = WeightedRandom.preprocess_p(probs, [])
  #    assert wr.backend == WeightedRandom.Backend.WalkerAlias
  #    sample = WeightedRandom.take(wr, sample_size)
  #    d2 = Analysis.get_delta(probs, sample)
  #    dbg {:wam, d2}

  #    s1 = Enum.sum(d1) 
  #    s2 = Enum.sum(d2)
  #    dbg {s1, s2}
  #    cond do
  #      s1 == s2 -> dbg :equal
  #      s1 < s2 -> dbg :custom_is_better
  #      s1 > s2 -> dbg :wam_is_better
  #    end
  #    #if !Analysis.match_probability?(probs, sample, tolerance) do
  #    #  outcomes =
  #    #    probs
  #    #    |> Enum.with_index()
  #    #    |> Enum.map(fn {_, i} -> i end)
  #    #  
  #    #else
  #    #end

  #    #lows = Enum.map(wr.table.buckets, fn {_, i, _} -> i end)
  #    #highs = Enum.map(wr.table.buckets, fn {_, _, i} -> i end)
  #    #results = lows ++ highs
  #    #dbg results

  #    #frq = Analysis.get_frequency_of_results(sample)
  #    #dbg frq
  #    #assert frq == %{0 => 0.1, 1 => 0.9}
  #  end
  #end



end
