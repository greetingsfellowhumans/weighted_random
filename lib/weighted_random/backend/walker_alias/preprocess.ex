defmodule WeightedRandom.Backend.WalkerAlias2.Preprocess do
  alias WeightedRandom.Backend.WalkerAlias2.Types, as: BackendT
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


end
