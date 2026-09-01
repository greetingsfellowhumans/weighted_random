defmodule WeightedRandom.Utils.Types do

  @type index() :: pos_integer()

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
  Anything compatible with `Curves.define_bezier/2`.
  """
  @type curve_spec :: atom() | list({number(), number()})


  @typedoc ~s"""
  A float between 0.0, and 1.0
  """
  @type probability() :: float()


  @typedoc ~s"""
  A list of floats, representing percentages, that should add up to 1.0
  """
  @type probabilities :: list(probability())

  @type indexed_probability() :: {probability(), index()}

  @typedoc ~s"""
  A list of probabilities and their indices
  """
  @type indexed_probabilities() :: list(indexed_probability())


  @typedoc ~s"""
  See function docs for details.
  """
  @type opts :: keyword()


end
