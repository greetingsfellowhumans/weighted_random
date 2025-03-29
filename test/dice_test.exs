defmodule WeightedRandom.DiceTest do
  use ExUnit.Case
  alias WeightedRandom.{Dice, Die}
  import Dice
  # import Die
  doctest Dice
  doctest Die

  test "Basic Die rolls make sense" do
    :rand.seed(:exsss, {100, 101, 102})
    die = Die.new(%{sides: 6, weights: [%{target: 5, weight: 10, radius: 2}]})

    rolls =
      Stream.repeatedly(fn -> Die.roll(die).result end)
      |> Enum.take(25)

    assert rolls == [5, 4, 5, 5, 5, 5, 4, 4, 6, 5, 5, 3, 5, 6, 5, 6, 6, 5, 6, 6, 6, 5, 2, 5, 6]
  end

  test "~d works" do
    dice = ~d{6}
    assert is_struct(dice, Dice)
    assert Enum.count(dice.dice) == 1

    dice = ~d{4, 6}
    assert is_struct(dice, Dice)
    assert Enum.count(dice.dice) == 4

    dice = ~d{4, 12, 1}
    assert is_struct(dice, Dice)
    assert Enum.count(dice.dice) == 4
    assert dice.modifier == 1
  end

  test "Merging dice" do
    :rand.seed(:exsss, {100, 101, 102})
    d1 = ~d{2, 12}
    d2 = ~d{1, 20, -1}
    d3 = ~d{3, 6, 2}
    d4 = Dice.merge_dice([d1, d2, d3])
    assert d4.modifier == 1

    pre_total = d1.total + d2.total + d3.total
    assert pre_total == d4.total
    assert Dice.roll(d4).total != d4.total
  end
end
