defmodule WeightedRandom.Utils.Analysis do
  alias WeightedRandom.Utils.Types, as: T
  @doc ~s"""
  Given a list of random values, determine the probability of each value.
  This is basically the inverse of `WeightedRandom.rand_p/2`
  """
  @spec get_probabilities_from_results(results :: list()) :: list(float())
  def get_probabilities_from_results(results) do
    size = Enum.count(results)

    results
      |> Enum.frequencies()
      |> Map.new(fn {result, freq} -> {result, freq / size} end)
  end
  def get_probabilities_from_results_and_outcomes(results, outcomes, opts \\ []) do
    opts = Keyword.put_new(opts, :index, true)

    size = Enum.count(results)
    table = outcome_to_index_table(outcomes, opts)
    dbg table

    results
      |> Enum.frequencies()
      |> Map.new(fn {result, freq} ->
        dbg result
        {result, freq / size}
      end)
  end



  @doc ~s"""
  Given a list of probabilities, and a list of results, determine whether the results were roughly correct.

  By default we use a tolerance of `0.2` (i.e. 20%). If the results have a very large sample size, then you should be able lower the tolerance.
  """
  @spec get_delta(expected :: list(float()), results :: list()) :: list(float())
  def get_delta(expected, results) when is_list(results) do
    actual_freq = get_probabilities_from_results(results)

    expected
      |> Enum.with_index()
      |> Enum.map(fn {p, idx} ->
        actual = Map.get(actual_freq, idx)
        abs(p - actual)
      end)
  end

  @doc ~s"""
  Sum a list of numbers, and find it's delta from a target number

  ## Examples
      iex> sum_delta([0.5, 0.25, 0.25], 1.0)
      0.0
      iex> sum_delta([0.5, 0.25, 0.25, 0.5], 1.0)
      0.5
  """
  def sum_delta(numbers, target) when is_number(target) do
    abs(Enum.sum(numbers) - target)
  end


  @default_tolerance 0.05
  @doc ~s"""
  Determine whether two numbers are equal; within a very small rounding error.

  ## Examples
      iex> equalish?(0.5, 0.499999999, 0.01)
      true
      iex> equalish?(0.5, 0.6, 0.01)
      false
  """
  def equalish?(left, right), do: equalish?(left, right, @default_tolerance)
  def equalish?(left, right, tolerance) when is_number(left) and is_number(right), do: abs(left - right) <= tolerance
  def equalish?(left, right, tolerance) when is_list(left) and is_list(right) do
    Enum.zip(left, right)
      |> Enum.all?(fn {l, r} -> equalish?(l, r, tolerance) end)
  end


  def sum_equalish?(li, target), do: sum_equalish?(li, target, @default_tolerance)
  def sum_equalish?(li, target, tolerance) do
    sum_delta(li, target)
      |> equalish?(0.0, tolerance)
  end


  @doc ~s"""
  Given a list of deltas, determine whether they are all within the tolerance level.

  By default we use a tolerance of `0.2` (i.e. 20%). If the results have a very large sample size, then you should be able lower the tolerance.
  """
  @spec match_probability?(expected :: list(float()), results :: list(), tolerance :: float()) :: boolean()
  def match_probability?(expected, results, tolerance \\ @default_tolerance) do
    delta = get_delta(expected, results)
    Enum.all?(delta, &(&1 <= tolerance))
  end

  @doc ~s"""
  Given the list of outcomes, and list of weights, return the list of probabilities
  """
  @spec get_probabilities_from_weights(outcomes :: T.outcomes(), weights :: list(T.weight_spec()), opts :: list()) :: list(float())
  def get_probabilities_from_weights(outcomes, weights, opts \\ []) do
    opts = WeightedRandom.Input.Opts.from_weights_merge_opts(opts)
    inputs = WeightedRandom.Input.FromWeights.get_inputs(outcomes, weights, opts)
    inputs.probabilities
  end


  @doc ~s"""
  Returns a map of %{index => outcome}

  ## Examples
      iex> outcomes = 100..130//10
      iex> index_to_outcome_table(outcomes, [index: true])
      %{0 => 100, 1 => 110, 2 => 120, 3 => 130}
  """
  @spec index_to_outcome_table(outcomes :: T.outcomes(), opts :: list()) :: %{optional(integer()) => any()}
  def index_to_outcome_table(outcomes, opts) do
    if Keyword.get(opts, :index) do
      Enum.with_index(outcomes)
        |> Map.new(fn {v, i} -> {i, v} end)
    else
      Enum.with_index(outcomes)
        |> Map.new(fn {v, i} -> 
          {i, v}
        end)
    end
  end


  @doc ~s"""
  Returns a map of %{outcome => index}

  ## Examples
      iex> outcomes = 100..130//10
      iex> outcome_to_index_table(outcomes, [index: true])
      %{100 => 0, 110 => 1, 120 => 2, 130 => 3}
  """
  @spec outcome_to_index_table(outcomes :: T.outcomes(), opts :: list()) :: %{optional(integer()) => any()}
  def outcome_to_index_table(outcomes, _opts) do
    Enum.with_index(outcomes)
      |> Map.new(fn {v, i} -> {v, i} end)
  end
end
