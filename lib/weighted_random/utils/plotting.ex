defmodule WeightedRandom.Utils.Plotting do
  def results_to_bars(results) when is_list(results) do
    results
      |> Enum.group_by(&(&1), fn _ -> true end)
      |> Enum.map(fn {outcome, items} ->
        %{outcome: outcome, hits: Enum.count(items)}
      end)
  end
end
