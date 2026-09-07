defmodule WeightedRandom.Backends.WalkerAlias.PreprocessTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Equalish
  alias WeightedRandom.Backend.WalkerAlias.Preprocess, as: Mod
  doctest Mod

  describe "WalkerAlias Preprocessing module" do
    @tag :skip
    property "should prep numbers correctly, when given a list of probabilities" do
      check all floats <- StreamData.list_of(StreamData.float(min: 0.01, max: 0.9), min_length: 1) do
        inputs = WeightedRandom.Input.FromProbabilities.get_inputs(floats, [])
        assert is_eq_ish(Enum.sum(inputs.probabilities), 1.0)
        {lows, highs, mean} = Mod.prep_numbers(inputs.probabilities)

        lp = Enum.map(lows, fn {p, _i} -> p end)
        hp = Enum.map(highs, fn {p, _i} -> p end)
        assert is_eq_ish(Enum.sum(lp ++ hp), 1.0)
      end
    end

    test "example 1" do
      probs = [0.2, 0.2, 0.6]
      {lows, highs, mean} = Mod.prep_numbers(probs)
      lp = Enum.map(lows, fn {p, _i} -> p end)
      hp = Enum.map(highs, fn {p, _i} -> p end)
      assert is_eq_ish(Enum.sum(lp ++ hp), 1.0)

      assert is_eq_ish(mean, 0.33)
    end

    @tag :skip
    test "example 2" do
      probs = [0.5940625, 0.455]
      assert is_eq_ish(Enum.sum(probs), 1.0)

      {lows, highs, mean} = Mod.prep_numbers(probs)
      lp = Enum.map(lows, fn {p, _i} -> p end)
      hp = Enum.map(highs, fn {p, _i} -> p end)
      dbg Enum.sum( lp ++ hp )
      assert is_eq_ish(Enum.sum(lp ++ hp), 1.0)

      assert is_eq_ish(mean, 0.33)
    end
  end


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
