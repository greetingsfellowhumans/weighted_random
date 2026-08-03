defmodule WeightedRandom.Backends.WalkerAliasTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.WalkerAlias, as: Mod

  test "Build the table" do
    probabilities = [
      {{1, 15}, 0},
      {{4, 15}, 1},
      {{1, 15}, 2},
      {{1, 15}, 3},
      {{1, 15}, 4},
      {{1, 15}, 5},
      {{1, 15}, 6},
      {{1, 15}, 7},
      {{1, 15}, 8},
      {{1, 15}, 9},
      {{1, 15}, 10},
      {{1, 15}, 11}
    ]
    table = Mod.preprocess(probabilities, [])
    assert table.li == [
      0, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ]
  end

  test "take" do
    probabilities = [
      {{1, 15}, 0},
      {{4, 15}, 1},
      {{1, 15}, 2},
      {{1, 15}, 3},
      {{1, 15}, 4},
      {{1, 15}, 5},
      {{1, 15}, 6},
      {{1, 15}, 7},
      {{1, 15}, 8},
      {{1, 15}, 9},
      {{1, 15}, 10},
      {{1, 15}, 11}
    ]
    table = Mod.preprocess(probabilities, [])
    [n] = Mod.take(table, 1)
    assert is_integer(n)
  end
end
