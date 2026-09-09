defmodule WeightedRandom.Utils.Analysis do
  @moduledoc ~s"""
  Utilities for backend developers to test the accuracy of their results.
  """
  @default_tolerance 0.05

  require Equalish
  alias WeightedRandom.Utils.Types, as: T


  @doc ~s"""
  Given a list of random values, determine the probability of each value.

  ## Examples
      iex> get_frequency_of_results([0, 1, 2, 2, 2, 2, 2, 2])
      %{0 => 0.125, 1 => 0.125, 2 => 0.75}
  """
  @spec get_frequency_of_results(results :: list()) :: %{optional(result :: any()) => count :: integer()}
  def get_frequency_of_results(results) do
    size = Enum.count(results)

    results
      |> Enum.frequencies()
      |> Map.new(fn {result, freq} -> {result, freq / size} end)
  end

  @doc ~s"""
  Given a list of random values, determine the probability of each value.
  Return list is in the same order as the second argument.

  This is basically the inverse of `WeightedRandom.rand_p/2`

  ## Examples
      iex> get_probabilities_from_results([1, 2, 2, 2, 2, 2, 2, 0], 0..2)
      [0.125, 0.125, 0.75]
  """
  @spec get_probabilities_from_results(results :: list(), outcomes :: list()) :: list(float())
  def get_probabilities_from_results(results, outcomes) do
    table = get_frequency_of_results(results)
    Enum.map(outcomes, fn v ->
      Map.get(table, v, 0.0)
    end)
  end


  @doc ~s"""
  Given a list of probabilities, and a sample of random results, determine how close those results were to their probabilities.

  This returns the absolute values, so they will never be negative.

  ## Examples
      iex> probs = [0.25, 0.5, 0.25]
      iex> results = [0, 1, 1, 2]
      iex> get_delta(probs, results)
      [0.0, 0.0, 0.0]

      iex> probs = [0.5, 0.5]
      iex> results = [0, 1, 1, 1]
      iex> get_delta(probs, results)
      [0.25, 0.25]
  """
  @spec get_delta(expected :: list(float()), results :: list()) :: list(float())
  def get_delta(expected, results) when is_list(results) do
    actual_freq = get_frequency_of_results(results)

    expected
      |> Enum.with_index()
      |> Enum.map(fn {p, idx} ->
        actual = Map.get(actual_freq, idx) || 0.0
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
  @spec sum_delta(numbers :: list(number()), target :: number()) :: number()
  def sum_delta(numbers, target) when is_number(target) do
    abs(Enum.sum(numbers) - target)
  end


  @doc ~s"""
  Determine whether two numbers are equal; within a very small rounding error.

  This function is just a wrapper around the `Equalish` library, but allows list comparisons.

  ## Examples
      iex> equalish?(0.5, 0.499999999, 0.01)
      true
      iex> equalish?(0.5, 0.6, 0.01)
      false
      iex> equalish?([0.5, 0.2, 0.3], [0.4999, 0.2001, 0.3])
      true
  """
  @spec equalish?(left :: number() | list(number()), right :: number() | list(number()), tolerance :: T.tolerance()) :: boolean()
  def equalish?(left, right), do: equalish?(left, right, @default_tolerance)
  def equalish?(left, right, tolerance) when is_number(left) and is_number(right) do
    Equalish.is_eq_ish(left, right, tolerance)
  end
  def equalish?(left, right, tolerance) when is_list(left) and is_list(right) do
    Enum.zip(left, right)
      |> Enum.all?(fn {l, r} -> Equalish.is_eq_ish(l, r, tolerance) end)
  end


  @doc ~s"""
  Determine whether a list of numbers, when summed, roughly equal the target

  ## Examples
      iex> sum_equalish?([0.1, 0.2], 0.3)
      true
  """
  @spec sum_equalish?(li :: list(number()), target :: number(), tolerance :: T.tolerance()) :: boolean()
  def sum_equalish?(li, target, tolerance \\ @default_tolerance) do
    sum_delta(li, target)
      |> Equalish.is_eq_ish(0.0, tolerance)
  end


  @doc ~s"""
  Given a list of expected probabilities, and a list of actual results (as indices), determine whether they are all within the tolerance level.

  If the results have a very large sample size, then you should be able lower the tolerance.

  This function will be more accurate with a higher sample size

  ## Examples
      iex> match_probability?([0.75, 0.25], [0, 1, 0, 0])
      true
      iex> match_probability?([0.75, 0.25], [0, 1, 0, 1])
      false
  """
  @spec match_probability?(expected :: list(float()), results :: list(T.index()), tolerance :: float()) :: boolean()
  def match_probability?(expected, results, tolerance \\ @default_tolerance) do
    delta = get_delta(expected, results)
    Enum.all?(delta, &(&1 <= tolerance))
  end


  @doc ~s"""
  Given the list of outcomes, and list of weights, return the list of probabilities

  ## Examples
      iex> get_probabilities_from_weights(1..6, [%{target: 3, weight: 2}], outcome_type: :value)
      [0.125, 0.125, 0.375, 0.125, 0.125, 0.125]
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
