defmodule WeightedRandom.Input do
  @moduledoc ~s"""
  The data structure for keeping track of weights and probability
  """
  defstruct [
    :weights,
    :probabilities,
    :outcomes,
    size: 0,
  ]


  @doc ~s"""
  Given a list of outcomes, create a new struct, setting each outcome to a weight of `1.0`
  """
  def from_outcomes(outcomes) do
    struct(__MODULE__, %{
      outcomes: outcomes,
      weights: Enum.map(outcomes, fn _ -> 1.0 end),
      size: Enum.count(outcomes)
    })
  end

  @doc ~s"""
  Given a list of floats, which must sum up to 1.0
  """
  def from_probabilities(probabilities) do
    size = Enum.count(probabilities)

    struct(__MODULE__, %{
      probabilities: probabilities,
      outcomes: 0..size + 1,
      size: Enum.count(probabilities)
    })
  end


  @doc ~s"""
  Acess the weight at a certain index
  """
  def at(prob, idx), do: Enum.at(prob.weights, idx)


  @doc ~s"""
  Add a certain amount of weight at a specific index
  """
  def add_weight(prob, weights) when is_list(weights) do
    Enum.reduce(weights, prob, fn w, prob ->
      add_weight(prob, w)
    end)
  end
  def add_weight(prob, %WeightedRandom.Input.Weight{target: idx, amount: amount} = weight) do
    prob
      |> add_weight(idx, amount)
      |> add_neighbour_weights_right(weight)
      |> add_neighbour_weights_left(weight)
  end
  def add_weight(prob, idx, amount) do
    %{prob | weights: List.update_at(prob.weights, idx, &(&1 + amount))}
  end


  defp add_neighbour_weights_right(prob, %{right_dist: r, curve: curve, target: target} = weight) when r > 0 do
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
  defp add_neighbour_weights_right(prob, _), do: prob

  defp add_neighbour_weights_left(prob, %{left_dist: l, curve: curve, target: target} = weight) when l > 0 do
    weights =
      curve
      |> Curves.take!(l)
      |> Enum.map(fn {_x, perc} ->
        (perc * weight.amount)
      end)
      |> Enum.reverse()
      |> tl()

    weights
    |> Enum.with_index(1)
    |> Enum.reduce(prob, fn {weight, idx}, prob ->
      add_weight(prob, target - idx, weight)
    end)
  end
  defp add_neighbour_weights_left(prob, _), do: prob


  def weights_to_probabilities(%__MODULE__{weights: weights, size: size}) do
    total_weight = Enum.sum(weights)
    equal_share = (size / total_weight) * 0.01
    Enum.map(weights, &(&1 * equal_share))
  end



  def probabilities_to_weights(probabilities) do
    smallest = Enum.min(probabilities)
    Enum.map(probabilities, fn p ->
      p / smallest
    end)
  end


end
