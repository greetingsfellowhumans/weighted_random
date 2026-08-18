defmodule WeightedRandom.Probability do
  alias WeightedRandom.Weight
  @moduledoc false

  def get_probabilities(outcomes, weights, opts) do
    weights = Weight.expand_weights(weights)
    sum = Enum.count(outcomes)

    case Keyword.get(opts, :probability_type, :float) do
      :float ->
        equal_share = get_equal_share(sum, weights, opts)
        outcomes = List.duplicate(equal_share, sum)
        Enum.reduce(weights, outcomes, fn %{target: idx, total_weight: w}, outcomes ->
          shares = w * equal_share
          List.update_at(outcomes, idx, &get_float(&1, shares, opts))
        end)
      :weight ->
        outcomes = List.duplicate(1, sum)
        total_shares = get_total_shares(sum, weights)
        Enum.reduce(weights, outcomes, fn %{target: idx, total_weight: w}, outcomes ->
          List.update_at(outcomes, idx, &(&1 + w))
        end)
          |> Enum.map(&{&1, total_shares})
    end
  end

  defp get_float(outcome, shares, opts) do
    with_precision(outcome + shares, opts)
  end

  def get_equal_share(count, expanded_weights), do: get_equal_share(count, expanded_weights, [])
  def get_equal_share(count, expanded_weights, opts) do
    total_shares = get_total_shares(count, expanded_weights)
    with_precision(1 / total_shares, opts)
  end

  defp with_precision(f, opts) do
    if precision = Keyword.get(opts, :precision) do
      Float.round(f, precision)
    else
      f
    end
  end

  defp get_total_shares(count, expanded_weights) do
    count + sum_weights(expanded_weights)
  end


  def sum_weights(expanded_weights) do
    Enum.reduce(expanded_weights, 0, fn %Weight{total_weight: amount}, acc ->
      acc + amount
    end)
  end


end
