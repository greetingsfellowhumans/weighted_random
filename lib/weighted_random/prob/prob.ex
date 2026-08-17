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
  def add_weight(prob, %WeightedRandom.Prob.Weight{target: idx, amount: amount} = weight) do
    prob
      |> add_weight(idx, amount)
      |> add_neighbour_weights_right(weight)
  end
  def add_weight(prob, idx, amount) do
    %{prob | weights: List.update_at(prob.weights, idx, &(&1 + amount))}
  end


  def add_neighbour_weights_right(prob, %{right_dist: r, curve: curve, target: target} = weight) do
    weights =
      curve
      |> Curves.take!(r)
      |> Enum.map(fn {_x, perc} ->
        (perc * weight.amount)
      end)
      |> Enum.reverse()
      |> tl()

    weights
    |> Enum.with_index(1)
    |> Enum.reduce(prob, fn {weight, idx}, prob ->
      add_weight(prob, target + idx, weight)
    end)
  end

end
