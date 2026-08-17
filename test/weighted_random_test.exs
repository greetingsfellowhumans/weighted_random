defmodule WeightedRandomTest do
  use ExUnit.Case
  doctest WeightedRandom

  describe "WeightedRandom module" do
    @tag skip: "@TODO come back after rebuilding probability"
    test "preprocess function" do
      :rand.seed(:exsss, {100, 101, 102})
      table = WeightedRandom.preprocess(0..100, [%{target: 25, weight: 50, radius: 10}])
      [n1, n2, n3, n4] = WeightedRandom.take(table, 4)
      assert [n1, n2, n3, n4] == [23, 65, 35, 19]

      table = WeightedRandom.preprocess(0..100, [%{target: 25, weight: 50, radius: 10}], [backend: WeightedRandom.Backend.Linear])
      [n1, n2, n3, n4] = WeightedRandom.take(table, 4)
      assert [n1, n2, n3, n4] == [46, 20, 25, 22]

      single = WeightedRandom.take(table)
      assert is_integer(single)

      p = WeightedRandom.get_probabilities(0..10, [%{target: 5, weight: 50, radius: 2}], [probability_type: :fraction])
      assert p == [
        {1, 111.0},
        {1, 111.0},
        {1, 111.0},
        {1, 111.0},
        {26.0, 111.0},
        {51, 111.0},
        {26.0, 111.0},
        {1, 111.0},
        {1, 111.0},
        {1, 111.0},
        {1, 111.0}
      ]
      p = WeightedRandom.get_probabilities(0..10, [%{target: 5, weight: 50, radius: 2}], [probability_type: :float, precision: 2, tag: :log])
      assert p == [0.01, 0.01, 0.01, 0.01, 0.26, 0.51, 0.26, 0.01, 0.01, 0.01, 0.01]
    end
  end
end
