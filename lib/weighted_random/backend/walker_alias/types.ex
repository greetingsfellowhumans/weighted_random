defmodule WeightedRandom.Backend.WalkerAlias2.Types do
  @type index() :: pos_integer()


  @typedoc ~s"""
  When a bucket has two values in it, the lower value takes up the space up to, and including the split_point. the higher value takes up the remainder
  """
  @type split_point() :: float()


  @typedoc ~s"""
  The Walker Alias method sorts n probabilities into n buckets.
  Every bucket has exactly 2 outcomes in it, which may or may not be duplicated. They  are split on the split point.

  For example, if a bucket has 25% outcome 1, and 75% outcome 5, then it looks like `{0.25, 1, 5}`
  """
  @type bucket() :: {split_point(), lower_index :: index, higher_index :: index}

end
