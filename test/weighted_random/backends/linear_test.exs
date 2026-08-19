defmodule WeightedRandom.Backends.LinearTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.Linear, as: Mod

  test "Build the table" do
    opts = [backend: Mod]
           |> WeightedRandom.Utils.Opts.merge_opts()

    input = WeightedRandom.Input.FromWeights.get_inputs(200..300, [%{target: 5, weight: 25}], opts)
    assert is_struct(input, WeightedRandom.Input)

    table = Mod.preprocess(input, opts)
    assert is_struct(table, Mod)
    assert Enum.count(table.li) == Enum.count(200..300) + 25
  end

  @tag :skip
  test "take" do
    opts = [backend: Mod]
    input = WeightedRandom.Input.FromWeights.get_inputs(200..300, [%{target: 5, weight: 25}], opts)
    table = Mod.preprocess(input, opts)
    li = Mod.take(table, 2)
    dbg li
  end
end
