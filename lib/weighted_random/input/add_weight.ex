defmodule WeightedRandom.Input.AddWeight do
  
  @doc ~s"""
  Add a certain amount of weight at a specific index
  """
  def add_weight(prob, weights) when is_list(weights) do
    Enum.reduce(weights, prob, fn w, prob ->
      add_weight(prob, w)
    end)
  end
  def add_weight(prob, %WeightedRandom.Input.Weight{target: _idx, amount: _amount} = weight) do
    prob
      |> add_target_weight(weight)
      |> add_neighbour_weights_right(weight)
      |> add_neighbour_weights_left(weight)
  end
  def add_weight(prob, idx, amount) do
    %{prob | weights: List.update_at(prob.weights, idx, &(&1 + amount))}
  end

  # New problem.
  # if the curve starts high and goes down, like :linear_down_right,
  # then there is A huge spike at the first index, before droppng to zero and slowly climbing.
  # Expected behaviour would be that actually the starting spike is correct, and then the curve glides down from there.
  defp add_target_weight(prob, %WeightedRandom.Input.Weight{target: idx, amount: amount, right_dist: rd, left_dist: ld, curve: _curve}) do
    amount = cond do
      rd > 0 -> 0
      ld > 0 -> 0
      true -> amount
    end

    add_weight(prob, idx, amount)
  end


  defp add_neighbour_weights_right(prob, %{right_dist: r, curve: curve, target: target} = weight) when r > 0 do
    weights =
      curve
      |> Curves.take!(r + 1)
      |> Enum.map(fn {_x, perc} ->
        (perc * weight.amount)
      end)
      |> Enum.reverse()
      |> tl()

    weights
    |> Enum.with_index(0)
    |> Enum.reduce(prob, fn {weight, idx}, prob ->
      add_weight(prob, target + idx, weight)
    end)
  end
  defp add_neighbour_weights_right(prob, _), do: prob


  defp add_neighbour_weights_left(prob, %{right_dist: rd, left_dist: ld, curve: curve, target: target} = weight) when ld > 0 do
    take_amount = if rd == 0, do: ld + 1, else: ld
    start_index = if rd == 0, do: 0, else: 1
    weights =
      curve
      |> Curves.take!(take_amount)
      |> Enum.map(fn {_x, perc} ->
        (perc * weight.amount)
      end)
      |> Enum.reverse()
      |> tl()

    weights
    |> Enum.with_index(start_index)
    |> Enum.reduce(prob, fn {weight, idx}, prob ->
      add_weight(prob, target - idx, weight)
    end)
  end
  defp add_neighbour_weights_left(prob, _), do: prob


end
