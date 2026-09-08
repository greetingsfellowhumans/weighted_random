defmodule WeightedRandom.Backends.WalkerAlias.PreprocessTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Equalish
  alias WeightedRandom.Backend.WalkerAlias.Preprocess, as: Mod
  doctest Mod

  describe "WalkerAlias Preprocessing module" do
    property "should prep numbers correctly, when given a list of probabilities" do
      check all tolerance <- StreamData.float(min: 1.0e-10, max: 1.0e-5),
                floats <- StreamData.list_of(StreamData.float(min: 1.0e-4, max: 1.0), min_length: 1) do
        opts = [tolerance: tolerance]
        inputs = WeightedRandom.Input.FromProbabilities.get_inputs(floats, opts)
        assert is_eq_ish(Enum.sum(inputs.probabilities), 1.0)
        {lows, highs, mean} = Mod.prep_numbers(inputs.probabilities)

        lp = Enum.map(lows, fn {p, _i} -> p end)
        hp = Enum.map(highs, fn {p, _i} -> p end)
        assert is_eq_ish(Enum.sum(lp ++ hp), 1.0)
        assert is_float(mean)
        assert mean <= 1.0
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

    test "example 2" do
      probs = [0.5940625, 0.455]
              |> WeightedRandom.Input.Normalize.normalize_probabilities([tolerance: 1.0e-10])
      assert is_eq_ish(Enum.sum(probs), 1.0)

      {lows, highs, mean} = Mod.prep_numbers(probs)
      lp = Enum.map(lows, fn {p, _i} -> p end)
      hp = Enum.map(highs, fn {p, _i} -> p end)
      assert is_eq_ish(Enum.sum(lp ++ hp), 1.0)

      assert is_eq_ish(mean, (hd(lp) + hd(hp)) / 2)
    end
  end


end
