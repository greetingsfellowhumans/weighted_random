defmodule WeightedRandom.Input.Weight do
  @moduledoc false
  @default_curve :ease_in_out

  @enforce_keys [:target, :amount, :left_dist, :right_dist, :expanded?]
  defstruct [
    :target,
    :amount,
    :curve,
    left_dist: 0,
    right_dist: 0,
    expanded?: false
  ]

  def new(body) do
    body = 
      body
      |> rename_amount()
      |> add_dist()
      |> add_default_curve()
      |> normalize_curve()
    struct(__MODULE__, body)
  end

  # Doing this to maintain backward compatibility
  # But also "amount" is much clearer than the old "weight"
  defp rename_amount(%{weight: w} = body), do: Map.put(body, :amount, w)
  defp rename_amount(body), do: body

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

  defp add_default_curve(%{curve: c} = body) when not is_nil(c), do: body
  defp add_default_curve(%{left_dist: d} = body) when d > 0, do: Map.put(body, :curve, @default_curve)
  defp add_default_curve(%{right_dist: d} = body) when d > 0, do: Map.put(body, :curve, @default_curve)
  defp add_default_curve(body), do: body
end
