defmodule WeightedRandom.Input.FromProbabilities do
  alias WeightedRandom.Input
  @moduledoc false


  def get_inputs(probabilities, opts) when is_list(probabilities) do
    #validate!(probabilities, opts)

    input = Input.from_probabilities(probabilities)
    Map.put(input, :weights, Input.probabilities_to_weights(probabilities))
  end

  defp validate!(probabilities, _opts) do
    rem = (1.0 - Enum.sum(probabilities)) |> Float.round(10)
    if rem != 0.0, do: raise "Invalid probabilities. Expected a list of floats that add up to exactly 1.0. Instead they add up to #{rem + 1.0}"
  end


end
