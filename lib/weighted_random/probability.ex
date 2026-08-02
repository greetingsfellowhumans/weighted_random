defmodule WeightedRandom.Probability do
  alias WeightedRandom.Weight
  @moduledoc false


  def get_probabilities(outcomes, weights, opts) do
    weights = Weight.expand_weights(weights)
    sum = Enum.count(outcomes)

    case Keyword.get(opts, :probability_type, :float) do
      :float ->
        equal_share = get_equal_share(sum, weights)
        outcomes = List.duplicate(equal_share, sum)
        Enum.reduce(weights, outcomes, fn %{target: idx, total_weight: w}, outcomes ->
          shares = w * equal_share
          List.update_at(outcomes, idx, &(&1 + shares))
        end)
      :fraction ->
        outcomes = List.duplicate(1, sum)
        total_shares = get_total_shares(sum, weights)
        Enum.reduce(weights, outcomes, fn %{target: idx, total_weight: w}, outcomes ->
          #shares = w * equal_share
          List.update_at(outcomes, idx, &(&1 + w))
        end)
          |> Enum.map(&{&1, total_shares})

    end


  end


  def get_equal_share(count, expanded_weights) do
    total_shares = get_total_shares(count, expanded_weights)
    1 / total_shares
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
