defmodule WeightedRandom.Input.NormalizeTest do
  use ExUnit.Case
  use ExUnitProperties
  import Equalish

  describe "Normalize" do
    property "Probabilities should always sum to 1.0" do
      check all floats <- StreamData.list_of(StreamData.float(min: 0.00001, max: 1.0), min_length: 1),
                tolerance <- StreamData.float(min: 0.000000000001, max: 0.1) do
        opts = [tolerance: tolerance]
        probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats, opts)
        sum = Enum.sum(probabilities)
        assert is_eq_ish(sum, 1.0, tolerance)
      end
    end
  end

end
