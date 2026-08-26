defmodule WeightedRandom.Input.AddWeight do
  @moduledoc false

  # Add a certain amount of weight at a specific index
  def add_weight(prob, weights) when is_list(weights) do
    Enum.reduce(weights, prob, fn w, prob ->
      add_weight(prob, w)
    end)
  end

  ## If no curve, then just add the weight to the one idx.
  def add_weight(prob, %WeightedRandom.Input.Weight{target: idx, amount: amount, curve: nil}) do
    add_weight(prob, idx, amount)
  end
  def add_weight(prob, %WeightedRandom.Input.Weight{target: target, curve: curve, left_dist: ld, right_dist: rd, amount: amount} ) do
    curve_length = 1 + ld + rd
    points = for n <- 0..curve_length do
      Curves.solve!(curve, n / curve_length)
    end
    ys = Enum.map(points, fn {_, y} -> y end)
    sum = Enum.sum(ys)
    percs = Enum.map(ys, fn y -> y / sum end)

    percs
      |> Enum.with_index(target - ld - 1)
      |> Enum.reduce(prob, fn {perc, idx}, prob ->
        add_weight(prob, idx, perc * amount)
      end)
  end
  def add_weight(prob, idx, amount) do
    %{prob | weights: List.update_at(prob.weights, idx, &(&1 + amount))}
  end

end
