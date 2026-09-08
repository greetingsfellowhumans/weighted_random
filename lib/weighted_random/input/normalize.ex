defmodule WeightedRandom.Input.Normalize do
  @moduledoc false
  import Equalish

  #@tolerance 1.0e-10

  # Given a list of floats, return a list of floats that must sum to 1.0
  def normalize_probabilities(floats, opts) when is_list(floats) do
    tolerance = opts[:tolerance]
    sum = Enum.sum(floats)
    cond do
      is_eq_ish(sum, 1.0, tolerance) -> floats
      is_lte_ish(sum, 0.0, tolerance) -> raise WeightedRandom.Exceptions.NonPositiveProbability, floats
      true ->
        multiplier = 1 / sum

        Enum.map(floats, fn 
          neg when is_lte_ish(neg, 0.0, tolerance) -> raise WeightedRandom.Exceptions.NonPositiveProbability, neg
          f when is_number(f) -> f * multiplier
          _ -> raise WeightedRandom.Exceptions.NonFloatProbabilities, floats
        end)
    end
  end



end
