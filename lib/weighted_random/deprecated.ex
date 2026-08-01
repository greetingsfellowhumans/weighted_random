defmodule WeightedRandom.Deprecated do
  @moduledoc false

  def between(min, max), do: Enum.random(min..max)

  def numList(min, max, length) do
    Enum.reduce(0..length, [], fn _, acc -> [Enum.random(min..max) | acc] end)
  end

  def weighted(min, max, target, weight) do
    range = numList(min, max, weight)

    Enum.reduce(range, min, fn curr, acc ->
      new = abs(target - curr)
      old = abs(target - acc)
      closer = new < old

      case closer do
        true -> curr
        false -> acc
      end
    end)
  end

  def complex(maplist) do
    result =
      Enum.reduce(maplist, %{:roll => 0, :value => nil}, fn %{:value => value, :weight => weight},
                                                            acc ->
        roll = weighted(0, 100, 100, weight)
        closer = roll > acc.roll

        case closer do
          true -> %{:roll => roll, :value => value}
          false -> acc
        end
      end)

    result.value
  end

end
