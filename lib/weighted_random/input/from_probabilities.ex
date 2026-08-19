defmodule WeightedRandom.Input.FromProbabilities do
  alias WeightedRandom.Input
  @moduledoc false


  def get_inputs(probabilities, _opts) when is_list(probabilities) do
    input = Input.from_probabilities(probabilities)
    Map.put(input, :weights, Input.probabilities_to_weights(probabilities))
  end


end
