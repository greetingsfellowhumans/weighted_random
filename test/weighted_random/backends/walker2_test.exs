defmodule WeightedRandom.Backends.Walker2Test do
  use ExUnit.Case
  use ExUnitProperties
  alias WeightedRandom.Backend.WalkerAlias2, as: Mod
  alias WeightedRandom.Utils.Analysis


  describe "Preprocess" do
    property "Split the probabilities" do
      check all floats <- StreamData.list_of(StreamData.float(min: 0.000001, max: 1.0), min_length: 1) do
        probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats)
        table = WeightedRandom.preprocess_p(probabilities, [backend: Mod])
        dbg table
      end
    end
  end

  #describe "WalkerAlias Analysis" do
  #  test "Weights, indexed" do
  #    opts = [backend: Mod, take: 1_000, outcome_type: :index]
  #    outcomes = 100..200
  #    weights = [%{target: 50, weight: 50, radius: 15}]
  #    results = WeightedRandom.rand(outcomes, weights, opts)

  #    assert Enum.count(results) == 1_000

  #    exp_probabilities = Analysis.get_probabilities_from_weights(outcomes, weights, opts)
  #    actual_probabilities = Analysis.get_probabilities_from_results(results, outcomes)
  #    assert Analysis.equalish?(exp_probabilities, actual_probabilities, 0.05)
  #  end

  #  test "Weights, values" do
  #    opts = [backend: Mod, take: 1_000, outcome_type: :value]
  #    outcomes = 100..200
  #    weights = [%{target: 150, weight: 50, radius: 15}]
  #    results = WeightedRandom.rand(outcomes, weights, opts)

  #    assert Enum.count(results) == 1_000

  #    exp_probabilities = Analysis.get_probabilities_from_weights(outcomes, weights, opts)
  #    actual_probabilities = Analysis.get_probabilities_from_results(results, outcomes)
  #    assert Analysis.equalish?(exp_probabilities, actual_probabilities, 0.05)
  #  end

  #  test "Probabilities" do
  #    opts = [backend: Mod, take: 1_000]
  #    probabilities = [0.1, 0.05, 0.05, 0.2, 0.6]
  #    results = WeightedRandom.rand_p(probabilities, opts)

  #    assert Enum.count(results) == 1_000

  #    outcomes = Enum.with_index(probabilities) |> Enum.map(fn {_, i} -> i end)
  #    actual_probabilities = Analysis.get_probabilities_from_results(results, outcomes)
  #    assert Analysis.equalish?(probabilities, actual_probabilities, 0.05)
  #  end
  #end

  #test "Build the table" do
  #  :rand.seed(:exsss, {100, 101, 102})
  #  probabilities = [
  #    0.1,
  #    0.5,
  #    0.1,
  #    0.1,
  #    0.1,
  #    0.9,
  #    0.1,
  #    2.1,
  #    0.1,
  #    0.1,
  #  ]
  #  table = Mod.preprocess(probabilities, [])
  #  assert is_struct(table, WAM)
  #  assert table.values == {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
  #  results = Mod.take(table, 25)
  #  results = Enum.frequencies(results)
  #  assert results == %{0 => 1, 3 => 1, 5 => 4, 6 => 1, 7 => 15, 8 => 2, 9 => 1}
  #end


end

