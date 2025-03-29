defmodule WeightedRandom.Dice do
  alias WeightedRandom.Die
  alias WeightedRandom.Dice

  defstruct dice: [],
            modifier: 0,
            subtotal: 0,
            total: 0

  @doc """
  Directly create a Dice struct.
  """
  def new(body) do
    struct(__MODULE__, body)
    |> count_dice()
  end

  @doc """
  Convenience sigil for creating dice
  ## Examples
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> d = ~d{4, 6, 1} # Equal to 4d6+1 in standard dice notation
      iex> [die1 | _] = d.dice
      iex> die1
      %WeightedRandom.Die{sides: 6, weights: [], result: 2}
      iex> d.subtotal
      10
      iex> d.total
      11
  """
  def sigil_d(str, _opts \\ []) do
    {quantity, sides, modifier} =
      str
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
      |> case do
        [s] -> {1, s, 0}
        [q, s] -> {q, s, 0}
        [q, s, m] -> {q, s, m}
      end

    dice = for _ <- 1..quantity, do: Die.new(%{sides: sides})
    Dice.new(%{dice: dice, modifier: modifier})
  end

  defp count_dice(dice) do
    count = Enum.reduce(dice.dice, 0, &(&1.result + &2))
    %{dice | subtotal: count, total: count + dice.modifier}
  end

  @doc """
  Takes a Dice struct and rerolls it.
  ## Examples
      iex> :rand.seed(:exsss, {200, 301, 402})
      iex> dice = ~d{2, 12}
      iex> dice.total
      8
      iex> Dice.roll(dice).total
      16

  """
  def roll(d) do
    dice = Enum.map(d.dice, &Die.roll/1)

    d
    |> Map.put(:dice, dice)
    |> count_dice()
  end

  @doc """
  Take a list of Dice structs, and combine them without rerolling
  """
  def merge_dice([dice]), do: dice

  def merge_dice([dice1, dice2 | tl]) do
    d3 = merge_dice(dice1, dice2)
    merge_dice([d3 | tl])
  end

  def merge_dice(dice1, dice2) do
    Dice.new(%{
      dice: dice1.dice ++ dice2.dice,
      modifier: dice1.modifier + dice2.modifier
    })
  end

  @doc """
  Adds weight to ALL dice in the Dice struct.

  ## Examples
      iex> :rand.seed(:exsss, {205, 301, 402})
      iex> d = ~d{10, 20} 
      iex> Enum.map(d.dice, &(&1.result))
      [17, 10, 1, 16, 17, 15, 11, 16, 12, 3]
      iex> d = Dice.add_weight(d, [%{target: 2, weight: 25}])
      iex> d = Dice.roll(d)
      iex> Enum.map(d.dice, &(&1.result))
      [2, 2, 2, 2, 3, 2, 2, 2, 18, 6]
  """
  def add_weight(dice, weight) do
    dices = Enum.map(dice.dice, fn die -> Die.add_weight(die, weight) end)
    Map.put(dice, :dice, dices)
  end
end
