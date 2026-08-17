defmodule WeightedRandom.Weight do
  @moduledoc false
  @type curve :: :linear | :ease | :ease_in | :ease_out | :ease_in_out | :ease_in_quad | :ease_in_cubic | :ease_in_quart | :ease_in_quint | :ease_in_sine | :ease_in_expo | :ease_in_circ | :ease_in_back | :ease_out_quad | :ease_out_cubic | :ease_out_quart | :ease_out_quint | :ease_out_sine | :ease_out_expo | :ease_out_circ | :ease_out_back | :ease_in_out_quad | :ease_in_out_cubic | :ease_in_out_quart | :ease_in_out_quint | :ease_in_out_sine | :ease_in_out_expo | :ease_in_out_circ | :ease_in_out_back
  @enforce_keys [
    :target,
  ]
  defstruct [
    :target,
    expanded?: false,
    #internal_weight: 1,
    total_weight: 1,
    radius: 1,
    curve: :linear,
    data_type: :integer
  ]
  @type t :: %__MODULE__{
    target: any(),
    expanded?: boolean(),
    #internal_weight: integer(),
    total_weight: integer(),
    radius: integer(),
    curve: curve(),
    data_type: atom()
  }



  def new(%{target: target} = opts, _global_opts \\ []) do
    weight = Map.get(opts, :weight, 1)

    body = %{
      target: target,
      #internal_weight: weight,
      total_weight: weight,
    }
    opts = 
      opts
      |> Map.delete(:weight)

    body = Map.merge(body, opts)

    struct!(__MODULE__, body)
  end

  # If non-struct maps are in the list, convert them to struct.
  def normalize(weights) do
    Enum.map(weights, fn 
      %__MODULE__{} = w -> w
      w -> new(w)
    end)
  end

  # Given a list of weights, return the list in addition to all side effect weights.
  def expand_weights(weights) do
    weights
      |> normalize()
      |> Enum.reduce([], fn 
      %__MODULE__{expanded?: false} = w, acc ->
        neighbours = create_side_effect_weights(w)
        [%{w | expanded?: true} | neighbours] ++ acc

      w, acc -> 
        [w | acc]
      end)
    |> Enum.sort_by(&(&1.target))
  end

  def create_side_effect_weights(%{target: t1, radius: r, total_weight: w1, curve: curve} = weight) do
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


  def weight_at_location(t1, t2, r, w1, curve_spec \\ :linear) do
    perc = distance_perc(t1, r, t2)
    curve = Curves.define_bezier(curve_spec)
    {_, weight_perc} = Curves.solve!(curve, perc)
    (1 - weight_perc) * w1
  end

  def generate_empty_neighbours(%{target: t1, radius: r} = _weight) do
    right = Range.new(t1 + 1, t1 + r) |> Enum.map(&(new(%{target: &1, expanded?: true})))
    left = Range.new(t1 - 1, t1 - r, -1) |> Enum.map(&(new(%{target: &1, expanded?: true})))
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
    w = round(w)
    Enum.map(1..w, fn _ -> t end)
  end

end
