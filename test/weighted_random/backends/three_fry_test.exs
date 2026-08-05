defmodule WeightedRandom.Backends.ThreeFryTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.ThreeFry, as: Mod

  test "Build the table" do
    probabilities = [
      0.1,
      0.5,
      0.1,
      0.1,
      0.1,
      0.9,
      0.1,
      2.1,
      0.1,
      0.1,
    ]
    table = Mod.preprocess(probabilities, [])
    assert is_struct(table.tensor, Nx.Tensor)
  end

  test "take" do
    probabilities = [
      0.1,
      0.5,
      0.1,
      0.1,
      0.1,
      0.9,
      0.1,
      2.1,
      0.1,
      0.1,
    ]
    table = Mod.preprocess(probabilities)
    {_key, li1} = Mod.take(table, 2, key: 42)
    {key, li2} = Mod.take(table, 2, key: 42)
    assert li1 == li2
    {_key, li3} = Mod.take(table, 2, key: key)
    refute li2 == li3
    assert is_list(li3)
    assert Enum.all?(li3, &is_integer/1)


  end
end
