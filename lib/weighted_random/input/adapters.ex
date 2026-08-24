defmodule WeightedRandom.Input.Adapters do
  @moduledoc false

  def probabilities_to_weights(probabilities) do
    smallest = Enum.min(probabilities)
    Enum.map(probabilities, fn p ->
      p / smallest
    end)
  end

  def weights_to_probabilities(%WeightedRandom.Input{weights: weights}) do
    total_weights = Enum.sum(weights)
    Enum.map(weights, &(&1 / total_weights))
  end
end
