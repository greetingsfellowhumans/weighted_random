#defmodule WeightedRandom.Backends.DataframeWalkerTest do
#  use ExUnit.Case
#  alias WeightedRandom.Backend.DataframeWalker, as: Mod
#
#  describe "WalkerAlias Backend" do
#    test "Integration" do
#      weights = [
#        %{target: 3, weight: 5, radius: 2},
#        %{target: 5, weight: 5, radius: 3},
#      ]
#      results = WeightedRandom.rand(1..10, weights, [backend: Mod, take: 1, with_index: false])
#      dbg results
#    end
#  end
#
#  @tag :skip
#  test "Build the table" do
#    :rand.seed(:exsss, {100, 101, 102})
#    probabilities = [
#      {0, 0.1},
#      {1, 0.5},
#      {2, 0.1},
#      {3, 0.1},
#      {4, 0.1},
#      {5, 0.9},
#      {6, 0.1},
#      {7, 2.1},
#      {8, 0.1},
#      {9, 0.1},
#    ]
#    table = Mod.preprocess(probabilities, [])
#    assert table.values == {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
#    results = Mod.take(table, 25)
#    #results = Enum.frequencies(results)
#    #dbg results
#  end
#
#  @tag :skip
#  test "take" do
#    probabilities = [
#      {{1, 15}, 0},
#      {{4, 15}, 1},
#      {{1, 15}, 2},
#      {{1, 15}, 3},
#      {{1, 15}, 4},
#      {{1, 15}, 5},
#      {{1, 15}, 6},
#      {{1, 15}, 7},
#      {{1, 15}, 8},
#      {{1, 15}, 9},
#      {{1, 15}, 10},
#      {{1, 15}, 11}
#    ]
#    table = Mod.preprocess(probabilities, [])
#    [n] = Mod.take(table, 1)
#    assert is_integer(n)
#  end
#end
