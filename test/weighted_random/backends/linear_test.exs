defmodule WeightedRandom.Backends.LinearTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.Linear, as: Mod

  test "Build the table" do
    opts = [backend: Mod]
    input = WeightedRandom.Input.FromWeights.get_inputs(200..300, [], opts)
    assert is_struct(input, WeightedRandom.Input)

    table = Mod.preprocess(input, opts)
    assert is_struct(table, Mod)
    assert Enum.count(table.li) == Enum.count(200..300)
  end

  @tag :skip
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
    [n] = Mod.take(table, 1)
    assert is_integer(n)
  end
end
