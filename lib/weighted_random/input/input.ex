defmodule WeightedRandom.Input do
  @moduledoc false
  defstruct [
    :weights,
    :probabilities,
    :outcomes,
    size: 0,
  ]


  @doc false
  def from_outcomes(outcomes) do
    struct(__MODULE__, %{
      outcomes: outcomes,
      weights: Enum.map(outcomes, fn _ -> 1.0 end),
      size: Enum.count(outcomes)
    })
  end

  @doc false
  def from_probabilities(probabilities) do
    size = Enum.count(probabilities)

    struct(__MODULE__, %{
      probabilities: probabilities,
      outcomes: 0..size + 1,
      size: Enum.count(probabilities)
    })
  end


  @doc false
  def at(prob, idx), do: Enum.at(prob.weights, idx)


  defdelegate add_weight(input, weight), to: WeightedRandom.Input.AddWeight

  defdelegate probabilities_to_weights(probabilities), to: WeightedRandom.Input.Adapters
  defdelegate weights_to_probabilities(input), to: WeightedRandom.Input.Adapters




end
