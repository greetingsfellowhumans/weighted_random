defmodule WeightedRandom.Backends.LinearTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.Linear, as: Mod

  test "Build the table" do
    probabilities = [
      {1, 15},
      {4, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15}
    ]
    table = Mod.preprocess(probabilities, [])
    assert table.li == [
      0, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ]
  end

  test "take" do
    probabilities = [
      {1, 15},
      {4, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15},
      {1, 15}
    ]
    table = Mod.preprocess(probabilities, [])
    [n] = Mod.take(table, 1, [])
    assert is_integer(n)
  end
end
