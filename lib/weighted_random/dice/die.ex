defmodule WeightedRandom.Die do
  @moduledoc ~s"""
  Represents a single Die, with a certain number of sides, weights, and current result.
  """
  @enforce_keys [:sides, :weights, :result]
  defstruct sides: 6,
            weights: [],
            preprocessed: nil,
            result: nil

  @type t :: %__MODULE__{
    preprocessed: struct(),
    sides: integer(),
    weights: list(),
    result: any()
  }
  def new(body, _opts \\ []) do
    struct(__MODULE__, body)
      |> add_preprocess()
      |> roll()
  end

  defp add_preprocess(%__MODULE__{sides: sides, weights: weights} = die) do
    pre = WeightedRandom.preprocess(1..sides, weights, index: false)
    Map.put(die, :preprocessed, pre)
  end

  def roll(%__MODULE__{preprocessed: pre} = die) do
    [result] = WeightedRandom.take(pre, 1)

    die
      |> Map.put(:result, result)
  end

  def add_weight(die, weights) when is_list(weights) do
    Enum.reduce(weights, die, fn w, d -> add_weight(d, w) end)
  end

  def add_weight(die, weight) do
    new_weights = [weight | die.weights]
    pre = WeightedRandom.preprocess(1..die.sides, new_weights, index: false)
    die
      |> Map.put(:weights, new_weights)
      |> Map.put(:preprocessed, pre)
  end
end
