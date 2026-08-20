defmodule WeightedRandom.Utils.Analysis do
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


  @doc ~s"""
  Given a list of probabilities, and a list of results, determine whether the results were roughly correct.

  By default we use a tolerance of `0.2` (i.e. 20%). If the results have a very large sample size, then you should be able lower the tolerance.
  """
  @spec get_delta(expected :: list(float()), results :: list()) :: list(float())
  def get_delta(expected, results) do
    actual_freq = get_probabilities_from_results(results)

    expected
      |> Enum.with_index()
      |> Enum.map(fn {p, idx} ->
        actual = Map.get(actual_freq, idx)
        abs(p - actual)
      end)
  end


  @default_tolerance 0.2
  @doc ~s"""
  Given a list of deltas, determine whether they are all within the tolerance level.

  By default we use a tolerance of `0.2` (i.e. 20%). If the results have a very large sample size, then you should be able lower the tolerance.
  """
  @spec match_probability?(expected :: list(float()), results :: list(), tolerance :: float()) :: boolean()
  def match_probability?(expected, results, tolerance \\ @default_tolerance) do
    delta = get_delta(expected, results)
    Enum.all?(delta, &(&1 <= tolerance))
  end


end
