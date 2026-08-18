defmodule WeightedRandom.Input.FromWeights do
  alias WeightedRandom.Input
  @moduledoc false


  def get_inputs(outcomes, weights, opts) when is_list(weights)  do
    weights = convert_weights_to_indices(outcomes, weights, opts)
              |> Enum.map(&Input.Weight.new/1)
    input = Input.from_outcomes(outcomes)
            |> Input.add_weight(weights)
    Map.put(input, :probabilities, Input.weights_to_probabilities(input))
  end


  defp convert_weights_to_indices(outcomes, weights, opts) do
    if Keyword.get(opts, :index) do
      weights
    else
      Enum.map(weights, fn w -> 
        t = Enum.find_index(outcomes, &(&1 == w.target))
        Map.put(w, :target, t)
      end)
    end
  end


end
