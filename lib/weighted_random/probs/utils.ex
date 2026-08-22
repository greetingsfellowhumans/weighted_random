defmodule WeightedRandom.Probs.Utils do

  # Given any list of positive numbers, map it to a list of floats that sum to 1.0 (within margin of rounding error)
  def nums_to_probabilities(nums) when is_list(nums) do
    total = Enum.sum(nums)
    Enum.map(nums, &(&1 / total))
  end

end
