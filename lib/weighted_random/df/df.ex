defmodule WeightedRandom.Df do
  def new(outcomes, _weights, opts) do
    precision = Keyword.get(opts, :precision, 3)
    sum = Enum.count(outcomes)
    equal_share = Float.round(1 / sum, precision)

    build_equal(sum, equal_share)
      #|> add_weights(weights, equal_share)
  end

  #defp add_weights(li, weights, equal_share) do
  #  Enum.reduce(weights, li, fn %WeightedRandom.Weight{target: idx, total_weight: total_weight}, li ->
  #    List.update_at(li, idx, &(&1 + (equal_share * total_weight)))
  #  end)
  #end

  defp build_equal(sum, equal_share) do
    r = 1..sum
    r
      |> Enum.map(fn _ -> equal_share end)
  end
end
