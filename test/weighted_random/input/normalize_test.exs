defmodule WeightedRandom.Input.NormalizeTest do
  use ExUnit.Case
  use ExUnitProperties

  describe "Normalize" do
    property "Probabilities should always sum to 1.0" do
      check all floats <- StreamData.list_of(StreamData.float(min: 0.00001, max: 1.0), min_length: 1) do
        probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats)
        sum = Enum.sum(probabilities)
        assert WeightedRandom.Utils.Analysis.equalish?(sum, 1.0)
      end
    end
  end

end
