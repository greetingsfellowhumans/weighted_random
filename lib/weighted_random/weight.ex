defmodule WeightedRandom.Weight do
  @moduledoc false
  defstruct [
    :target,
    internal_weight: 1,
    total_weight: 1,
    radius: 1,
    curve: :linear,
    data_type: :integer
  ]

  def new(%{target: target} = opts, _global_opts \\ []) do
    weight = Map.get(opts, :weight, 1)

    body = %{
      target: target,
      internal_weight: weight,
      total_weight: weight,
    }
    opts = 
      opts
      |> Map.delete(:weight)

    body = Map.merge(body, opts)

    struct!(__MODULE__, body)
  end

  def create_side_effect_weights(%{target: t1, radius: r, internal_weight: w1, curve: curve} = weight) do
    neighbours = generate_empty_neighbours(weight)
    Enum.map(neighbours, fn %{target: t2} = neighbour ->
      w2 = weight_at_location(t1, t2, r, w1, curve)
      Map.put(neighbour, :total_weight, w2)
    end)
    |> Enum.filter(&(&1.total_weight != 0))
  end

  def distance_perc(target, radius, neighbour_target) do
    distance = abs(target - neighbour_target)
    distance / radius
  end


  def weight_at_location(t1, t2, r, w1, curve \\ :linear) do
    perc = distance_perc(t1, r, t2)
    weight_perc = WeightedRandom.CubicBezier.solve(perc, curve)
    round((1 - weight_perc) * w1)
  end

  def generate_empty_neighbours(%{target: t1, radius: r} = _weight) do
    right = Range.new(t1 + 1, t1 + r) |> Enum.map(&(new(%{target: &1})))
    left = Range.new(t1 - 1, t1 - r) |> Enum.map(&(new(%{target: &1})))
    List.flatten(right ++ left)
    |> Enum.sort_by(&(&1.target))
  end

  def convert_to_values(weights) when is_list(weights) do
    weights
    |> List.flatten()
    |> Enum.map(&split/1)
    |> List.flatten()
  end

  def split(%{target: t, total_weight: w} = _weight) do
    Enum.map(1..w, fn _ -> t end)
  end

end
