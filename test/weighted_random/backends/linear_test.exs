defmodule WeightedRandom.Backends.LinearTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.Linear, as: Mod

  test "preprocess stores indices, take returns outcomes" do
    r = WeightedRandom.preprocess(200..300, [%{target: 5, amount: 25}], backend: Mod)
    assert is_struct(r.table, Mod)
    assert Enum.count(r.table.li) == Enum.count(200..300) + 25
    assert Enum.all?(r.table.li, &(&1 in 0..100))

    li = WeightedRandom.take(r, 4)
    assert Enum.count(li) == 4
    assert Enum.all?(li, &(&1 in 200..300))
  end

  test "outcome_type: :value favours the target value" do
    li = WeightedRandom.rand(200..300, [%{target: 205, amount: 25}],
           backend: Mod, outcome_type: :value, take: 400)

    assert Enum.all?(li, &(&1 in 200..300))
    {most_frequent, _} = li |> Enum.frequencies() |> Enum.max_by(&elem(&1, 1))
    assert most_frequent == 205
  end

  test "works with rand_p" do
    li = WeightedRandom.rand_p([0.25, 0.25, 0.5], backend: Mod, take: 10)
    assert Enum.all?(li, &(&1 in 0..2))
  end
end
