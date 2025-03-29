defmodule WeightedRandom do
  alias WeightedRandom.Weight

  @doc ~s"""
  Returns a random value based on the weights given
  """
  def rand(li, weights, opts \\ []) do
    weights = if is_list(weights), do: weights, else: [weights]
    default_opts = [index: true]

    use_indexes? =
      if !Enum.all?(li, &is_integer/1),
        do: true,
        else: Keyword.get(opts, :index, Keyword.get(default_opts, :index))

    unless use_indexes? do
      rand_ints(li, weights, opts)
    else
      idx_li = Enum.with_index(li)
      int_map = Enum.map(idx_li, fn {v, idx} -> {idx, v} end) |> Enum.into(%{})
      int_li = Map.keys(int_map)
      idx = rand_ints(int_li, weights, opts)
      Map.get(int_map, idx)
    end
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

  # {{{ Deprecated
  @doc false
  @deprecated "Please use `Enum.random` instead"
  def between(min, max), do: Enum.random(min..max)

  @doc false
  @deprecated "Please use `Enum.take_random` instead"
  def numList(min, max, length) do
    Enum.reduce(0..length, [], fn _, acc -> [between(min, max) | acc] end)
  end

  @doc false
  @deprecated "Please use WeightedRandom.rand instead"
  def weighted(min, max, target, weight) do
    range = numList(min, max, weight)

    Enum.reduce(range, min, fn curr, acc ->
      new = abs(target - curr)
      old = abs(target - acc)
      closer = new < old

      case closer do
        true -> curr
        false -> acc
      end
    end)
  end

  @doc false
  @deprecated "Please use WeightedRandom.rand instead"
  def complex(maplist) do
    result =
      Enum.reduce(maplist, %{:roll => 0, :value => nil}, fn %{:value => value, :weight => weight},
                                                            acc ->
        roll = weighted(0, 100, 100, weight)
        closer = roll > acc.roll

        case closer do
          true -> %{:roll => roll, :value => value}
          false -> acc
        end
      end)

    result.value
  end

  # }}}
end
