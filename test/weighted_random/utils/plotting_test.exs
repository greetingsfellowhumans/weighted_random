defmodule WeightedRandom.Utils.PlottingTest do
  use ExUnit.Case
  alias WeightedRandom.Utils.Plotting, as: Mod


  describe "Plotting utils" do
    test "Generate plottable probabilities" do
      outcomes = 1..10
      results = for _ <- 1..1000 do
        Enum.random(outcomes)
      end
      plot = Mod.results_to_bars(results)
      [%{outcome: 1, hits: n} | _] = plot
      assert is_integer(n)
    end

  end

end
