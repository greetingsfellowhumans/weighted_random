defmodule WeightedRandom do
  alias WeightedRandom.Utils.Types, as: T
  alias WeightedRandom.Input

  @moduledoc ~s"""
  ## Interactive Playground

  The best way to learn is through the [Livebook](guides/tutorial.livemd)

  # Quickstart

  The most optimal workflow is to:
  1. Define your requirements (outcomes, weights, probabilities, other options)
  2. Preprocess it to create a struct that is optimized for making future sampling faster
  2. Take n random values


  ### Randomness from probabilities

  ```elixir
  # Probabilities are floats representing percentages, that should add up to 1.0
  probabilities = [0.1, 0.6, 0.2, 0.1]
  optimized_struct = WeightedRandom.preprocess_p(probabilities)

  n = 5
  WeightedRandom.take(optimized_struct, n)
  #=> [1, 2, 1, 1, 1]
  ```

  Alternately, if you won't need the same probabilities again:
  ```elixir
  probabilities = [0.1, 0.6, 0.2, 0.1]
  WeightedRandom.rand_p(probabilities)
  #=> 1

  opts = [take: 5]
  WeightedRandom.rand_p(probabilities, opts)
  #=> [2, 1, 1, 2, 1]
  ```

  ### Randomness from outcomes and weights.

  When given 4 equal probabilities (25% each), you could also write them as `[1/4, 1/4, 1/4, 1/4]`.
  What if we simplified it into a list of `[1, 1, 1, 1]`, and automatically normalized it to divide each by the whole?
  That is exactly what a weight is.

  One benefit over probabilities is that you can adjust one weight without needing to manually recalculate all of them.

  To use this, we must now decouple the outcomes from the weights. Before, the index of the probability WAS the outcome.

  ```elixir
  outcomes = 0..3
  weight = %{target: 1, weight: 2}
  opts = []

  # under the hood, this creates the probabilities: `[1/5, 2/5, 1/5, 1/5]`
  optimized_struct = WeightedRandom.preprocess(outcomes, [weight], opts)

  n = 5
  WeightedRandom.take(optimized_struct, n)
  #=> [2, 1, 1, 0, 1]
  ```

  Be careful to call the right function.

  | Weights                       	| Probabilities                   	|
  |-------------------------------	|---------------------------------	|
  | `WeightedRandom.preprocess/3` 	| `WeightedRandom.preprocess_p/2` 	|
  | `WeightedRandom.rand/3`       	| `WeightedRandom.rand_p/2`       	|
  | `WeightedRandom.take/2`       	| `WeightedRandom.take/2`         	|



  Another benefit of weights is that you can do more than random numbers
  ```elixir
  outcomes = ["a", "b", :c, 3.14]
  weights = [%{target: 2, amount: 20}]
  WeightedRandom.rand(outcomes, weights)
  #=> :c
  ```

  Using the `:outcome_type` option, you can even target the value of an outcome, rather than the index.
  ```elixir
  outcomes = ["a", "b", :c, 3.14]
  weights = [%{target: "b", amount: 10}]
  WeightedRandom.rand(outcomes, weights, outcome_type: :value)
  #=> "b"

  weights = [%{target: 3.14, amount: 200} | weights]
  WeightedRandom.rand(outcomes, weights, outcome_type: :value)
  #=> 3.14
  ```


  ## Customizing weights
  A weight is a map with the following fields:

  #{NimbleOptions.docs(WeightedRandom.Input.Opts.weight_spec_schema())}

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
  @spec preprocess_p(T.probabilities(), T.opts()) :: WeightedRandom.Backend.t()
  def preprocess_p([f | _] = probabilities, opts \\ []) when is_number(f) do
    opts = Input.Opts.from_probabilities_merge_opts(opts)
    inputs = Input.FromProbabilities.get_inputs(probabilities, opts)
    WeightedRandom.Backend.preprocess(opts[:backend], inputs, opts)
  end


  @doc ~s"""
  Given a non-empty list (or range) of possible outcomes, and a list of weight maps, build a struct that can later be passed into `WeightedRandom.take/2` for very fast random sampling.

  ## Examples
      iex> r = WeightedRandom.preprocesses(0..10, [%{target: 2, amount: 1000}])
      iex> li = WeightedRandom.take(r, 5)
      [2, 2, 2, 2, 2]


  Supported options:\n#{NimbleOptions.docs(Input.Opts.from_weights_schema())}
  """
  @spec preprocess(T.outcomes(), list(T.weight_spec()), T.opts()) :: WeightedRandom.Backend.t()
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
  @spec take(WeightedRandom.Backend.t()) :: any()
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
  @spec take(WeightedRandom.Backend.t(), count :: integer()) :: list()
  def take(processed_struct, count) do
    WeightedRandom.Backend.take(processed_struct, count)
    |> convert_index_to_outcome(processed_struct.outcomes)
  end


  @doc ~s"""
  Returns a random value based on the weights given.
  If you need *a lot* of random numbers over time, this is suboptimal and you should use `preprocess` + `take` instead.

  Supported options:\n#{NimbleOptions.docs(Input.Opts.rand_docs())}
  """
  @spec rand(outcomes :: T.outcomes(), weights :: list(T.weight_spec()), T.opts()) :: any()
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
  @spec rand_p(T.probabilities(), T.opts()) :: any()
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
