defmodule WeightedRandom do
  #alias WeightedRandom.Weight

  @default_opts [index: true]
  @default_backend WeightedRandom.Backend.RuntimeList
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


  ## Opts
  * `:backend` [module]: WeightedRandom.Backend.RuntimeList

  """
  def rand(li, weights), do: rand(li, weights, [])
  def rand(li, weight, opts) when is_map(weight), do: rand(li, [weight], opts)
  def rand(li, weights, opts) when is_list(li) or is_struct(li, Stream) or is_struct(li, Range) do
    opts = Keyword.merge(@default_opts, opts)
    backend = get_backend(opts)

    weights = if Keyword.get(opts, :index) do
      weights
    else
      convert_weights_to_indices(li, weights)
    end
    dbg {li, weights}
    opts = Keyword.put(opts, :li, li)

    m = WeightedRandom.Backend.preprocess(backend, weights, opts)
    case Keyword.get(opts, :take) do
       n when is_integer(n) -> WeightedRandom.Backend.take(backend, m, 1)
       nil ->
        [x] = WeightedRandom.Backend.take(backend, m, 1)
        x
    end
  end


  defp convert_weights_to_indices(li, weights) do
    Enum.map(weights, fn w -> 
      t = Enum.find_index(li, &(&1 == w.target))
      Map.put(w, :target, t)
    end)
  end

  defp get_backend(opts) do
    case Keyword.fetch(opts, :backend) do
      {:ok, b} -> b
      _ -> case Application.fetch_env(:weighted_random, :backend) do
        {:ok, b} -> b
        _ -> @default_backend
      end
    end
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
