defmodule WeightedRandom.Backends.LinearTest do
  use ExUnit.Case
  alias WeightedRandom.Backend.Linear, as: Mod

  test "Index true" do
    opts = WeightedRandom.Input.Opts.from_weights_merge_opts([backend: Mod])

    input = WeightedRandom.Input.FromWeights.get_inputs(200..300, [%{target: 5, weight: 25}], opts)
    assert is_struct(input, WeightedRandom.Input)

    table = Mod.preprocess(input, opts)
    assert is_struct(table, Mod)
    assert Enum.count(table.li) == Enum.count(200..300) + 25

    li = Mod.take(table, 4)
    assert Enum.count(li) == 4
    assert Enum.all?(li, &(&1 <= 100))
  end

  test "index false" do
    target = 205
    weight = 25

    opts = [backend: Mod, index: false]
           |> WeightedRandom.Utils.Opts.merge_opts()

    input = WeightedRandom.Input.FromWeights.get_inputs(200..300, [%{target: target, weight: weight}], opts)
    assert is_struct(input, WeightedRandom.Input)

    table = Mod.preprocess(input, opts)
    assert is_struct(table, Mod)
    assert Enum.count(table.li) == Enum.count(200..300) + weight

    li = Mod.take(table, 400)
    assert Enum.all?(li, &(&1 >= 200))
    most_frequent = 
      Enum.frequencies(li)
      |> Enum.reduce(%{outcome: nil, frequency: 0}, fn 
        {outcome, freq}, %{outcome: _aout, frequency: afreq} when freq > afreq -> %{outcome: outcome, frequency: freq}
        _, acc -> acc
      end)
    assert most_frequent.outcome == target

  end
end
