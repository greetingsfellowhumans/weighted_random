defmodule WeightedRandom.Prob do
  @moduledoc ~s"""
  The data structure for keeping track of weights and probability
  """
  defstruct [
    size: 0,
    weights: [],
  ] 

  @doc ~s"""
  Creates a new %Prob{} struct
  """
  def new(outcomes) do
    struct(__MODULE__, %{
      weights: Enum.map(outcomes, fn _ -> 1.0 end),
      size: Enum.count(outcomes)
    })
  end

  @doc ~s"""
  Acess the weight at a certain index
  """
  def at(prob, idx), do: Enum.at(prob.weights, idx)

  @doc ~s"""
  Add a certain amount of weight at a specific index
  """
  def add_weight(prob, idx, amount \\ 1) do
    %{prob | weights: List.update_at(prob.weights, idx, &(&1 + amount))}
  end

end
