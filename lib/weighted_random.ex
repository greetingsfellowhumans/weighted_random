defmodule WeightedRandom do
  #alias WeightedRandom.Weight

  @default_opts [
    take: nil,
    index: true,
    precision: 3,
    probability_type: :float,
  ]
  @default_backend WeightedRandom.Backend.RuntimeList

  @doc ~s"""
  Given a list of items and a list of weights, map the list of items into a list of floats which sum to 1.0 (disregarding rounding errors)
  """
  defdelegate get_probabilities(outcomes, weights, opts), to: WeightedRandom.Probability


  @doc ~s"""
  Returns a random value based on the weights given.

  By default this operates on the index, not the value.

  #  ## Examples
  #      iex> :rand.seed(:exsss, {108, 101, 102})
  #      iex> li = 1..10
  #      iex> weights = [ %{target: 7, weight: 100} ]
  #      iex>
  #      iex> # By default this uses the index 7, not the *value* 7.
  #      iex> WeightedRandom.rand(li, weights)
  #      8
  #      iex> # But we can use the value by passing the option index: false
  #      iex> WeightedRandom.rand(li, weights, index: false)
  #      7
  #      iex> li = [:a, :b, :c, :d, :e, :f, :g, :h, :j, :k, :l]
  #      iex> WeightedRandom.rand(li, weights)
  #      :h
  #      iex> weights = [ %{target: :d, weight: 100} ]
  #      iex> WeightedRandom.rand(li, weights, index: false)
  #      :d


  ## Opts
  * `:take` [integer | nil]: `nil`. If used, then instead of returning one random value, will return a list of random value with size equal to take.
  * `:backend` [module]: WeightedRandom.Backend.RuntimeList
  * `:probability_type` [:float | :fraction]: :float. To avoid floating point precision issues, you can use :fraction so that the probabilities are all tuples of `{numenator :: integer(), denominator :: integer()}` In which they all have the same denominator which equals the sum of all numinators.
  * `:precision` [integer]: 3. Only applies when the `probability_type` is `:float`. Probability floats will be rounded to this number of decimal places.

  """
  def rand(outcomes, weights), do: rand(outcomes, weights, [])
  def rand(outcomes, weight, opts) when is_map(weight), do: rand(outcomes, [weight], opts)
  def rand(outcomes, weights, opts) when is_list(outcomes) or is_struct(outcomes, Stream) or is_struct(outcomes, Range) do
    opts = Keyword.merge(@default_opts, opts)
    backend = get_backend(opts)
    backend_opts = backend.options()
    opts = Keyword.merge(opts, backend_opts)

    weights = if Keyword.get(opts, :index) do
      weights
    else
      convert_weights_to_indices(outcomes, weights)
    end

    p = get_probabilities(outcomes, weights, opts)
        |> Enum.with_index()

    table = WeightedRandom.Backend.preprocess(backend, p, opts)
    case Keyword.get(opts, :take) do
       n when is_integer(n) -> 
         WeightedRandom.Backend.take(backend, table, n)
          |> convert_index_to_outcome(outcomes)
       nil ->
        [idx] = WeightedRandom.Backend.take(backend, table, 1)
        convert_index_to_outcome(idx, outcomes)
    end
  end

  defp convert_index_to_outcome(indices, outcomes) when is_list(indices) do
    Enum.map(indices, &convert_index_to_outcome(&1, outcomes))
  end
  defp convert_index_to_outcome(index, outcomes) when is_integer(index) do
    Enum.at(outcomes, index)
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
