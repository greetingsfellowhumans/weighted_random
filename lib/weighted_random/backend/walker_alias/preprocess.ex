defmodule WeightedRandom.Backend.WalkerAlias2.Preprocess do
  alias WeightedRandom.Utils.Types, as: T

  @doc ~s"""
  Returns two lists, the underweight, and the overweight probabilities (preserving their original index)
  """
  @spec split_probabilities(T.indexed_probabilities(), mean :: float()) :: {lower :: T.indexed_probabilities(), higher :: T.indexed_probabilities()}
  def split_probabilities(indexed_probabilities, mean) do
    indexed_probabilities = Enum.sort_by(indexed_probabilities, fn {p, _i} -> p end, :asc)
    split_index = Enum.find_index(indexed_probabilities, fn {p, _i} -> p >= mean end)
    Enum.split(indexed_probabilities, split_index)
  end


  @doc ~s"""
  Given a list of probabilities, return a tuple with the underweight list, overweight list, and mean.
  """
  @spec prep_numbers(T.probabilities()) :: {T.indexed_probabilities(), T.indexed_probabilities(), float()}
  def prep_numbers(probabilities) do
    sum = Enum.sum(probabilities)
    length = Enum.count(probabilities)
    mean = sum / length

    {lows, highs} = Enum.with_index(probabilities)
                  |> split_probabilities(mean)

    highs = Enum.reverse(highs)
    {lows, highs, mean}
  end

end
