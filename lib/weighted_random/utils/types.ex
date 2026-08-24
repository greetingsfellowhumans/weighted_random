defmodule WeightedRandom.Utils.Types do
  @typedoc ~s"""
  The values to be randomly picked from.
  """
  @type outcomes() :: nonempty_list() | Range.t()

  @typedoc ~s"""
  The weight, as given by the end user, which will influence the randomization.
  """
  @type weight_spec :: %{
    required(:target) => any(),
    required(:amount | :weight) => number(),
  }
end
