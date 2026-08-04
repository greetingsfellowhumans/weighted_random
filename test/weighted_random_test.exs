defmodule WeightedRandomTest do
  use ExUnit.Case
  doctest WeightedRandom

  describe "WeightedRandom module" do
    test "preprocess function" do
      :rand.seed(:exsss, {100, 101, 102})
      table = WeightedRandom.preprocess(0..100, [%{target: 25, weight: 50, radius: 10}])
      [n1, n2, n3, n4] = WeightedRandom.take(table, 4)
      assert [n1, n2, n3, n4] == [23, 65, 35, 19]

      table = WeightedRandom.preprocess(0..100, [%{target: 25, weight: 50, radius: 10}], [backend: WeightedRandom.Backend.Linear])
      [n1, n2, n3, n4] = WeightedRandom.take(table, 4)
      assert [n1, n2, n3, n4] == [46, 20, 25, 22]
    end
  end
end
