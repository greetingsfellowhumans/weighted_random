defmodule WeightedRandom.Backend.RuntimeList do
  alias WeightedRandom.Weight
  use WeightedRandom.Backend
  defstruct [
    int_li: [],
    int_map: [],
    weights: [],
    opts: [],
  ]

  @impl true
  def preprocess(weights, opts) do
    idx_li = Enum.with_index(opts[:li])
    int_map = Map.new(idx_li, fn {v, idx} -> {idx, v} end)
    int_li = Map.keys(int_map)
    struct(__MODULE__, %{int_li: int_li, weights: weights, int_map: int_map, opts: opts})
  end

  @impl true
  def take(%__MODULE__{int_li: int_li, int_map: int_map, weights: weights, opts: opts}, _count) do
    idx = rand_ints(int_li, weights, opts)
    sample = Map.get(int_map, idx)
    [sample]
  end

  defp rand_ints(li, weights, opts) do
    custom_weights = Enum.map(weights, &Weight.new(&1, opts))
    side_effects = Enum.map(custom_weights, &Weight.create_side_effect_weights/1)

    li =
      (Weight.convert_to_values(custom_weights) ++
         Weight.convert_to_values(side_effects) ++
         Enum.map(li, & &1))
      |> Enum.filter(&(&1 in li))

    Enum.random(li)
  end


end
