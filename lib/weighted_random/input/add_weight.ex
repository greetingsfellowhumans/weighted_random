defmodule WeightedRandom.Input.AddWeight do
  @moduledoc false

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

  defp add_target_weight(prob, %WeightedRandom.Input.Weight{target: idx, amount: amount, right_dist: rd, left_dist: ld, curve: _curve}) do
    amount = cond do
      rd > 0 -> 0
      ld > 0 -> 0
      true -> amount
    end

    add_weight(prob, idx, amount)
  end


  defp add_neighbour_weights_right(prob, %{right_dist: r, amount: amount, curve: curve, target: target}) when r > 0 do
    weights =
      0..r
      |> Enum.map(fn idx ->
        perc = idx / (r)
        {_x, y} = Curves.solve!(curve, perc)
        y * amount
      end)
      |> Enum.reverse()

    weights
    |> Enum.with_index(0)
    |> Enum.reduce(prob, fn {weight, idx}, prob ->
      add_weight(prob, target + idx, weight)
    end)
  end
  defp add_neighbour_weights_right(prob, _), do: prob


  defp add_neighbour_weights_left(prob, %{amount: amount, right_dist: rd, left_dist: ld, curve: curve, target: target}) when ld > 0 do
    take_amount = if rd == 0, do: ld + 1, else: ld
    start_index = if rd == 0, do: 0, else: 1
    weights =
      1..take_amount
      |> Enum.map(fn idx ->
        perc = idx / (ld + 1)
        {_x, y} = Curves.solve!(curve, perc)
        y * amount
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
