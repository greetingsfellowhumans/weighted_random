defmodule WeightedRandom.Die do
  @moduledoc false
  defstruct sides: 6,
            weights: [],
            result: nil

  def new(body, _opts \\ []) do
    struct(__MODULE__, body)
    |> roll()
  end

  def roll(%__MODULE__{sides: sides, weights: weights} = die) do
    Map.put(die, :result, WeightedRandom.rand(1..sides, weights, index: false))
  end

  def add_weight(die, weights) when is_list(weights) do
    Enum.reduce(weights, die, fn w, d -> add_weight(d, w) end)
  end

  def add_weight(die, weight) do
    Map.update!(die, :weights, &[weight | &1])
  end
end
