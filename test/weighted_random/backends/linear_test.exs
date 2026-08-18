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

  test "take" do
    probabilities = [0.1, 0.1, 0.3]
    input = WeightedRandom.Input.FromProbabilities.get_inputs(probabilities, [])
    table = Mod.preprocess(input, [])
    samples = Mod.take(table, 100)
    assert Enum.count(samples) == 100
    [n | _] = samples
    assert is_integer(n)
    groups = Enum.frequencies(samples)
    assert groups[0] < groups[2]
    assert groups[1] < groups[2]
  end
end
