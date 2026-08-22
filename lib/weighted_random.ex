defmodule WeightedRandom do
  alias WeightedRandom.Utils.Opts
  alias WeightedRandom.Input

  @moduledoc ~s"""

  ## Usage

  ```elixir
  table = WeightedRandom.preprocess(0..100, [%{target: 25, weight: 50, radius: 10}])
  [n1, n2, n3, n4] = WeightedRandom.take(table, 4)
  ```

  Alternately, if you care less about performance, you can do it all at once:
  ```elixir
  [n1, n2, n3, n4] = WeightedRandom.rand(0..100, [%{target: 25, weight: 50, radius: 10}], [take: 4])
  ```

  But please note the algorithm is optimized to take a long time ( O(n) ) during preprocessing, in order to be very fast during the sampling step ( O(1) ).
  So it will be far better to preprocess once, and take many times. `rand/3` preprocesses EVERY time it is called.
  """

  @default_opts [
    take: nil,
    index: true,
    precision: nil,
    probability_type: :float,
  ]

  @doc ~s"""
  Given a non-empty list of percentages, build a struct that can later be used for very fast random sampling, matching those probabilities.

  Supported options:\n#{NimbleOptions.docs(WeightedRandom.Input.Opts.from_probabilities_schema())}
  """
  def from_probabilities([f | _] = probabilities, opts \\ []) when is_number(f) do
    opts = WeightedRandom.Input.Opts.from_probabilities_merge_opts(opts)
    inputs = Input.FromProbabilities.get_inputs(probabilities, opts)
    WeightedRandom.Backend.preprocess(opts[:backend], inputs, opts)
  end


  @doc ~s"""
  Given a non-empty list of possible outcomes, and a list of weight maps, build a struct that can later be used for very fast random sampling.

  Supported options:\n#{NimbleOptions.docs(WeightedRandom.Input.Opts.from_weights_schema())}
  """
  def from_weights(outcomes, weights, opts \\ []) when is_list(weights) do
    opts = WeightedRandom.Input.Opts.from_weights_merge_opts(opts)
    inputs = Input.FromWeights.get_inputs(outcomes, weights, opts)
    WeightedRandom.Backend.preprocess(opts[:backend], inputs, opts)
  end


  def take(processed_struct) do
    WeightedRandom.Backend.take(processed_struct, 1)
      |> convert_index_to_outcome(processed_struct.outcomes)
      |> List.first()
  end
  def take(processed_struct, count) do
    WeightedRandom.Backend.take(processed_struct, count)
    |> convert_index_to_outcome(processed_struct.outcomes)
  end


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
  * `:backend` [module]: WeightedRandom.Backend.WalkerAlias. We also provide WeightedRandom.Backend.Linear which can have slightly better performance if you are not taking that many samples. Worse performance in most other cases.
  * `:index` [boolean]: true. Whether the `:target` of a `%WeightedRandom.Weight{}` points at an index of the outcomes (if true), or at the actual value of one of the outcomes (if false).
  * `:probability_type` [:float | :fraction]: :float. To avoid floating point precision issues, you can use :fraction so that the probabilities are all tuples of `{numenator :: integer(), denominator :: integer()}` In which they all have the same denominator which equals the sum of all numinators.
  * `:precision` [integer]: 3. Only applies when the `probability_type` is `:float`. Probability floats will be rounded to this number of decimal places.
  * `:take` [integer | nil]: `nil`. If used, then instead of returning one random value, will return a list of random value with size equal to take.

  """
  def rand(outcomes, weights), do: rand(outcomes, weights, [])
  def rand(outcomes, weight, opts) when is_map(weight), do: rand(outcomes, [weight], opts)
  def rand(outcomes, weights, opts) when is_list(weights) do
    processed_struct = from_weights(outcomes, weights, opts)
    case Keyword.get(opts, :take) do
       n when is_integer(n) -> 
         WeightedRandom.Backend.take(processed_struct, n)
          |> convert_index_to_outcome(outcomes)
       nil ->
        [idx] = WeightedRandom.Backend.take(processed_struct, 1)
        convert_index_to_outcome(idx, outcomes)
    end
  end

  @doc ~s"""
  similar to `rand/3` but instead of a list of outcomes, and a list of weights, `rand_p/3` accepts a list of probability floats.
  """
  def rand_p(probabilities, opts \\ []) when is_list(probabilities) do
    processed_struct = from_probabilities(probabilities, opts)
    case Keyword.get(opts, :take) do
       n when is_integer(n) -> 
         WeightedRandom.Backend.take(processed_struct, n)
       nil ->
        [idx] = WeightedRandom.Backend.take(processed_struct, 1)
        idx
    end
  end

  defp convert_index_to_outcome(indices, outcomes) when is_list(indices)  do
    Enum.map(indices, &convert_index_to_outcome(&1, outcomes))
  end
  defp convert_index_to_outcome(index, outcomes) when is_integer(index) do
    Enum.at(outcomes, index)
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
