defmodule WeightedRandom do
  alias WeightedRandom.Utils.Types, as: T
  alias WeightedRandom.Input

  @moduledoc ~s"""
  ## Livebook

  The best way to learn is through the interactive [Livebook tutorial](guides/tutorial.livemd)

  ## Usage

  ```elixir
  outcomes = 0..100
  weight = %{target: 25, weight: 50, radius: 10}
  r = WeightedRandom.preprocess(0..100, [weight])
  [n1, n2, n3, n4] = WeightedRandom.take(r, 4)
  ```

  Alternately, if you care less about performance, you can do it all at once:
  ```elixir
  [n1, n2, n3, n4] = WeightedRandom.rand(0..100, [%{target: 25, weight: 50, radius: 10}], [take: 4])
  ```

  But please note the algorithm is optimized to take a long time ( O(n) ) during preprocessing, in order to be very fast during the sampling step ( O(1) ).
  So it will be far better to preprocess once, and take many times. `rand/3` preprocesses EVERY time it is called.
  """


  @doc ~s"""
  Given a non-empty list of percentages (floats from 0.0 - 1.0), build the struct.

  Next, pass the resulting struct into `WeightedRandom.take/2` to get rand

  ## Examples
      iex> r = WeightedRandom.preprocess_p([0.01, 0.01, 0.98])
      iex> li = WeightedRandom.take(r, 5)
      [2, 2, 2, 2, 2]


  Supported options:\n#{NimbleOptions.docs(Input.Opts.from_probabilities_schema())}
  """
  def preprocess_p([f | _] = probabilities, opts \\ []) when is_number(f) do
    opts = Input.Opts.from_probabilities_merge_opts(opts)
    inputs = Input.FromProbabilities.get_inputs(probabilities, opts)
    WeightedRandom.Backend.preprocess(opts[:backend], inputs, opts)
  end


  @doc ~s"""
  Given a non-empty list (or range) of possible outcomes, and a list of weight maps, build a struct that can later be used for very fast random sampling.

  Next, pass the resulting struct into `WeightedRandom.take/2` to get rand

  ## Examples
      iex> r = WeightedRandom.preprocesses(0..10, [%{target: 2, amount: 1000}])
      iex> li = WeightedRandom.take(r, 5)
      [2, 2, 2, 2, 2]


  Supported options:\n#{NimbleOptions.docs(Input.Opts.from_weights_schema())}
  """
  def preprocess(outcomes, weights, opts \\ []) when is_list(weights) do
    opts = Input.Opts.from_weights_merge_opts(opts)
    inputs = Input.FromWeights.get_inputs(outcomes, weights, opts)
    WeightedRandom.Backend.preprocess(opts[:backend], inputs, opts)
  end


  @doc ~s"""
  Given a WeightedRandom struct, return a single random value.


  ## Examples
      iex> r = WeightedRandom.preprocesses(0..10, [%{target: 2, amount: 1000}])
      iex> li = WeightedRandom.take(r)
      2

  """
  def take(processed_struct) do
    WeightedRandom.Backend.take(processed_struct, 1)
      |> convert_index_to_outcome(processed_struct.outcomes)
      |> List.first()
  end


  @doc ~s"""
  Given a WeightedRandom struct, return a list of random values


  ## Examples
      iex> # Make the item at index 2 1000x more likely than any other single index.
      iex> r = WeightedRandom.preprocesses(0..10, [%{target: 2, amount: 1000}])
      iex> li = WeightedRandom.take(r, 3)
      [2, 2, 2]

  """
  def take(processed_struct, count) do
    WeightedRandom.Backend.take(processed_struct, count)
    |> convert_index_to_outcome(processed_struct.outcomes)
  end


  @doc ~s"""
  Returns a random value based on the weights given.
  If you need *a lot* of random numbers over time, this is suboptimal and you should use `preprocess` + `take` instead.

  Supported options:\n#{NimbleOptions.docs(Input.Opts.rand_docs())}
  """
  @spec rand(outcomes :: T.outcomes(), weights :: list(T.weight_spec()), opts :: list()) :: term()
  def rand(outcomes, weights, opts \\ []) do
    weights = if is_map(weights), do: [weights], else: weights
    r = preprocess(outcomes, weights, opts)
    opts = Input.Opts.rand_merge_opts(opts)
    case opts[:take] do
       n when is_integer(n) -> take(r, n)
       nil -> take(r)
    end
  end

  @doc ~s"""
  similar to `rand/3` but instead of a list of outcomes, and a list of weights, `rand_p/3` accepts a list of probability floats.
  If you need *a lot* of random numbers over time, this is suboptimal and you should use `preprocess` + `take` instead.

  Supported options:\n#{NimbleOptions.docs(Input.Opts.rand_p_docs())}
  """
  def rand_p(probabilities, opts \\ []) when is_list(probabilities) do
    r = preprocess_p(probabilities, opts)
    case Keyword.get(opts, :take) do
       n when is_integer(n) -> take(r, n)
       nil -> take(r)
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
