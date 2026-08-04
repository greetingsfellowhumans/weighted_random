defmodule WeightedRandom.Backends.WalkerAliasTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.WalkerAlias, as: Mod

  describe "WalkerAlias Backend" do
    test "Integration" do
      results = WeightedRandom.rand(1..100, [%{target: 50, weight: 50, radius: 15}], [backend: Mod, index: false, take: 1_000])
      assert Enum.count(results) == 1_000
      results = Enum.frequencies(results)
      assert results[50] > 10
    end
  end

  test "Build the table" do
    :rand.seed(:exsss, {100, 101, 102})
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
    #probabilities = Enum.with_index(probabilities)
    table = Mod.preprocess(probabilities, [])
    assert table.values == {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
    results = Mod.take(table, 25)
    results = Enum.frequencies(results)
    assert results == %{0 => 1, 3 => 1, 5 => 4, 6 => 1, 7 => 15, 8 => 2, 9 => 1}
  end

end
