defmodule WeightedRandom.Input.FromProbabilities do
  alias WeightedRandom.Input
  @moduledoc false


  def get_inputs(probabilities, opts) when is_list(probabilities) do
    input = Input.from_probabilities(probabilities, opts)
    Map.put(input, :weights, Input.probabilities_to_weights(probabilities))
  end


end
