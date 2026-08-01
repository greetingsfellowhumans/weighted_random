defmodule WeightedRandom do
  alias WeightedRandom.Weight

  @default_opts [index: true]

  @doc ~s"""
  Returns a random value based on the weights given.

  By default this operates on the index, not the value.

  ## Examples
      iex> :rand.seed(:exsss, {108, 101, 102})
      iex> li = 1..10
      iex> weights = [ %{target: 7, weight: 100} ]
      iex>
      iex> # By default this uses the index 7, not the *value* 7.
      iex> WeightedRandom.rand(li, weights)
      8
      iex> # But we can use the value by passing the option index: false
      iex> WeightedRandom.rand(li, weights, index: false)
      7
      iex> li = [:a, :b, :c, :d, :e, :f, :g, :h, :j, :k, :l]
      iex> WeightedRandom.rand(li, weights)
      :h
      iex> weights = [ %{target: :d, weight: 100} ]
      iex> WeightedRandom.rand(li, weights, index: false)
      :d
  """
  def rand(li, weights), do: rand(li, weights, [])
  def rand(li, weight, opts) when is_map(weight), do: rand(li, [weight], opts)
  def rand(li, weights, opts) when is_list(li) or is_struct(li, Stream) or is_struct(li, Range) do
    opts = Keyword.merge(@default_opts, opts)
    weights = if Keyword.get(opts, :index) do
      weights
    else
      convert_weights_to_indices(li, weights)
    end

    idx_li = Enum.with_index(li)
    int_map = Map.new(idx_li, fn {v, idx} -> {idx, v} end)
    int_li = Map.keys(int_map)
    idx = rand_ints(int_li, weights, opts)
    Map.get(int_map, idx)
  end

  defp convert_weights_to_indices(li, weights) do
    Enum.map(weights, fn w -> 
      t = Enum.find_index(li, &(&1 == w.target))
      Map.put(w, :target, t)
    end)
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

  @doc false
  @deprecated "Please use `Enum.random` instead"
  defdelegate between(min, max), to: WeightedRandom.Deprecated

  @doc false
  @deprecated "Please use `Enum.take_random` instead"
  defdelegate numList(min, max, length), to: WeightedRandom.Deprecated

  @doc false
  @deprecated "Please use WeightedRandom.rand instead"
  defdelegate weighted(min, max, target, weight), to: WeightedRandom.Deprecated

  @doc false
  @deprecated "Please use WeightedRandom.rand instead"
  defdelegate complex(maplist), to: WeightedRandom.Deprecated
end
