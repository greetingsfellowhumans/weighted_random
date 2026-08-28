defmodule WeightedRandom.Dice.Types do
  @typedoc ~s"""
  The map to later be turned into a Dice struct
  """
  @type dice_spec :: %{
    :dice => list(WeightedRandom.Die.t()),
    optional(:modifier) => integer()
  }

  @type num_dice :: pos_integer()
  @type dice_sides :: pos_integer()
  @type modifier :: integer()

  @typedoc ~S"""
  Widely used notation for describing dice.
  Within the context of WeightedRandom, there are two formats: string, and tuple.

  String: `"#{num_dice}d#{dice_sides}+#{modifier}"`

  Tuple: `{num_dice, dice_sides, modifier}` 

  In either case, `num_dice` and `modifier` are both optional


  ## String Examples

  - `"d8"` => A single die with 8 sides.
  - `"4d6"` => 4 dice with 6 sides each.
  - `"2d10+1"` => 2 dice, each with 10 sides, always adding `+1` to the total

  ## Tuple Examples
  - `{8}` => A single die with 8 sides.
  - `{4, 6}` => 4 dice with 6 sides each.
  - `{2, 10, 1}` => 2 dice, each with 10 sides, always adding `+1` to the total
  """
  @type standard_dice_notation() :: String.t()

end
