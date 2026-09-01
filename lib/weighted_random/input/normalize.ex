defmodule WeightedRandom.Input.Normalize do
  @moduledoc false

  # Given a list of floats, return a list of floats that must sum to 1.0
  def normalize_probabilities(floats) when is_list(floats) do
    sum = Enum.sum(floats)
    if WeightedRandom.Utils.Analysis.equalish?(sum, 1.0) do
      floats
    else
      multiplier = 1 / sum

      Enum.map(floats, fn 
        neg when neg <= 0 -> raise WeightedRandom.Exceptions.NonPositiveProbability, neg
        f when is_number(f) -> f * multiplier
      end)
    end
  end


end
