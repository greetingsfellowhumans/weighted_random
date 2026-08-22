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
    case opts[:outcome_type] do
      :index -> weights
      :value -> 
        Enum.map(weights, fn w -> 
          case Enum.find_index(outcomes, &(&1 == w.target)) do
            nil -> 
              raise "Unable to find an outcome that equals the weight target: #{w.target}. Perhaps you meant to use `outcome_type: :index`? Or you might have passed `index: false` (the deprecated version of the same option)."
            t -> Map.put(w, :target, t)
          end
        end)
    end
  end


end
