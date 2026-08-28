defmodule WeightedRandom.DiceTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias WeightedRandom.{Dice, Die}
  import Dice
  # import Die
  doctest Dice
  doctest Die

  defp gen_dice(sides, count, modifier) do
    case modifier do
      0 -> sigil_d("#{count}, #{sides}")
      pos when pos > 0 -> sigil_d("#{count}, #{sides}, +#{pos}")
      neg when neg < 0 -> sigil_d("#{count}, #{sides}, #{neg}")
    end
  end

  describe "sigil_d & Dice.new/1" do
    property "The right type, and number, of dice should be created" do
      check all sides <- StreamData.positive_integer(),
                count <- StreamData.positive_integer(),
                modifier <- StreamData.integer()
      do
        dice = gen_dice(sides, count, modifier)
        assert is_struct(dice, Dice)
        assert Enum.count(dice.dice) == count
        assert dice.modifier == modifier
        assert Enum.all?(dice.dice, &(&1.sides == sides))

        assert dice.total == modifier + Enum.sum_by(dice.dice, &(&1.result))
      end
    end
  end

  describe "Dice Rolls" do
    property "dice rolls should be within possible ranges" do
      check all sides <- StreamData.positive_integer(),
                count <- StreamData.positive_integer(),
                modifier <- StreamData.integer()
      do
        dice = gen_dice(sides, count, modifier)
               |> Dice.roll()
        assert dice.total <= (modifier + (sides * count))
        results = Dice.results(dice)
        assert Enum.sum(results) + modifier == dice.total
      end
    end
  end

  describe "Dice merge" do
    property "dice rolls should be within possible ranges" do
      check all sides_a <- StreamData.positive_integer(),
                sides_b <- StreamData.positive_integer(),
                count_a <- StreamData.positive_integer(),
                count_b <- StreamData.positive_integer(),
                modifier_a <- StreamData.integer(),
                modifier_b <- StreamData.integer()
      do
        d1 = gen_dice(sides_a, count_a, modifier_a)
        d2 = gen_dice(sides_b, count_b, modifier_b)
        dice = Dice.merge_dice([d1, d2])
               |> Dice.roll()
        assert is_struct(dice, Dice)
        assert Enum.count(dice.dice) == count_a + count_b
        assert dice.modifier == modifier_a + modifier_b
        assert Enum.all?(dice.dice, &(&1.sides == sides_a or &1.sides == sides_b))

        assert dice.total == modifier_a + modifier_b + Enum.sum_by(dice.dice, &(&1.result))
      end
    end
  end



end
