defmodule WeightedRandom.Prob.Weight do
  defstruct [
    :target,
    :amount,
    :curve,
    :left_dist,
    :right_dist,
    expanded?: false
  ]

  def new(body) do
    body = normalize_curve(body)
           |> add_dist()
    struct(__MODULE__, body)
  end

  defp add_dist(%{radius: n} = body) do
    body
      |> Map.put(:left_dist, n)
      |> Map.put(:right_dist, n)
  end
  defp add_dist(body), do: body

  defp normalize_curve(%{curve: curve_spec} = body) when is_atom(curve_spec) or is_list(curve_spec) do
    c = Curves.define_bezier(curve_spec, [force_percent: true])
    %{body | curve: c}
  end
  defp normalize_curve(body), do: body
end
