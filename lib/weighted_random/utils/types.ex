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
    optional(:left_dist) => integer(),
    optional(:right_dist) => integer(),
    optional(:radius) => integer(),
    optional(:curve) => curve_spec(),
  }


  @typedoc ~s"""
  Anything compatible with `Curves.define_bezier/3`.
  """
  @type curve_spec :: atom() | list({number(), number()})


  @typedoc ~s"""
  A list of floats, representing percentages, that should add up to 1.0
  """
  @type probabilities :: list(float())


  @typedoc ~s"""
  See function docs for details.
  """
  @type opts :: keyword()
end
