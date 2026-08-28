defmodule WeightedRandom.Dice do
  alias WeightedRandom.{Dice, Die}
  alias Dice.{Types, Opts}

  @moduledoc ~s"""
  # Dice
  
  ## Creating Dice

  ```elixir
  alias WeightedRandom.Dice
  import Dice

  # This creates 4 x 6-sided dice
  # In standard dice notation this would be written as "4d6"
  d = ~d{4, 6}

  # Alternately, create dice manually
  Dice.new(%{})
  ```

  Now let's make the number 2 have more weight.

  Dice always use `outcome_type: :value`, not `:index`, so the target is 2

  ```elixir
  d = ~d{4, 6}
  weights = [%{target: 2, amount: 50}]
  d = Dice.add_weight(d, weights)

  # Always remember to roll again so the new weight takes effect.
  d = Dice.roll(d)

  IO.inspect(Dice.results(d), label: "results")
  # => [2, 2, 3, 2]
  d.total
  # => 9
  ```

  """

  @enforce_keys [
    :dice, :modifier, :subtotal, :total
  ]
  defstruct dice: [],
            modifier: 0,
            subtotal: 0,
            total: 0

  @type t :: %__MODULE__{
    dice: list(%WeightedRandom.Die{}),
    modifier: integer(),
    total: integer(),
    subtotal: integer(),
  }


  @doc """
  Manually create a Dice struct. It is usually easier to use `sigil_d/2`.

  ## Eamples
      iex> die = WeightedRandom.Die.new(%{sides: 6})
      iex> dice = WeightedRandom.Dice.new(%{dice: [die]})
      iex> %WeightedRandom.Dice{dice: [d]} = dice
      iex> d == die
      true

  Takes a single map as an argument, with the following keys:\n
  #{NimbleOptions.docs(Opts.dice_new_body_docs())}
  """
  @spec new(Types.dice_spec()) :: __MODULE__.t()
  def new(dice_spec) do
    struct(__MODULE__, dice_spec)
    |> count_dice()
  end


  @doc """
  Convenience sigil for creating dice using standard notation.

  ## Tuple format

  ## Examples
      iex> d = ~d{4,6,-1} # Equal to 4d6-1 in standard dice notation
      iex> Enum.count(d.dice)
      4
      iex> Enum.all?(d.dice, &(&1.sides == 6))
      true


  ## String format

  ## Examples
      iex> d = ~d"2d8+3"
      iex> Enum.count(d.dice)
      2
      iex> Enum.all?(d.dice, &(&1.sides == 8))
      true
  """
  @spec sigil_d(Types.standard_dice_notation(), list()) :: __MODULE__.t()
  def sigil_d(str, _opts \\ []) do
    syntax_type = if String.contains?(str, "d"), do: :string, else: :tuple
    {count, sides, modifier} = split_sigil(str, syntax_type) |> join_sigil()

    dice = for _ <- 1..count, do: Die.new(%{sides: sides})
    Dice.new(%{dice: dice, modifier: modifier})
  end
  defp split_sigil(str, :tuple) do
    str
    |> String.split([", ", ","])
    |> Enum.map(&String.to_integer/1)
  end
  defp split_sigil(str, :string) do
    {count, tl} = case String.split(str, ["d"], trim: true) do
      [count, tl] -> {count, tl}
      [tl] -> {"1", tl}
    end

    [sides, modifier] = cond do
      String.contains?(tl, "+") -> String.split(tl, "+")
      String.contains?(tl, "-") -> 
        [sides, mod] = String.split(tl, "-")
        [sides, "-" <> mod]
      true -> [tl, "0"]
    end 

    [count, sides, modifier]
    |> Enum.map(&String.to_integer/1)
  end
  defp join_sigil([s]), do: {1, s, 0}
  defp join_sigil([q, s]), do: {q, s, 0}
  defp join_sigil([q, s, m]), do: {q, s, m}

  defp count_dice(dice) do
    count = Enum.reduce(dice.dice, 0, &(&1.result + &2))
    %{dice | subtotal: count, total: count + dice.modifier}
  end

  @doc """
  Takes a Dice struct and rerolls it.

  ## Examples
  ```elixir
  dice = ~d{2, 12}
  dice.total == 12

  dice = Dice.roll(dice)
  dice.total == 20
  ```

  """
  def roll(%__MODULE__{} = d) do
    dice = Enum.map(d.dice, &Die.roll/1)

    d
    |> Map.put(:dice, dice)
    |> count_dice()
  end
  def roll(%WeightedRandom.Die{} = d) do
    Die.roll(d)
  end

  @doc ~s"""
  Given some dice, return a list showing the result of each one.

  ## Examples
  ```elixir
  d = ~d"4d6"
  Dice.results(d) == [2, 5, 3, 4]
  ```
  """
  @spec results(dice :: __MODULE__.t()) :: list(integer())
  def results(%__MODULE__{dice: dice}) do
    Enum.map(dice, &(&1.result))
  end

  @doc """
  Take a list of Dice structs, and combine them without rerolling

  ## Examples
      iex> d1 = ~d{2, 6}
      iex> d2 = ~d{3, 10}
      iex> d3 = Dice.merge_dice([d1, d2])
      iex> is_struct(d3, Dice)
      true
  """
  @spec merge_dice(list(Dice.t())) :: Dice.t()
  def merge_dice([dice]), do: dice

  def merge_dice([dice1, dice2 | tl]) do
    d3 = merge_dice(dice1, dice2)
    merge_dice([d3 | tl])
  end

  @doc """
  Take two Dice structs, and combine them without rerolling

  ## Examples
      iex> d1 = ~d{2, 6}
      iex> d2 = ~d{3, 10}
      iex> d3 = Dice.merge_dice(d1, d2)
      iex> is_struct(d3, Dice)
      true
  """
  @spec merge_dice(Dice.t(), Dice.t()) :: Dice.t()
  def merge_dice(dice1, dice2) do
    Dice.new(%{
      dice: dice1.dice ++ dice2.dice,
      modifier: dice1.modifier + dice2.modifier
    })
  end

  @doc """
  Adds weight to ALL dice in the Dice struct.

  ## Examples
      iex> d = ~d{10, 20} 
      iex> d = Dice.add_weight(d, [%{target: 2, weight: 50}])
      iex> Enum.all?(d.dice, fn die -> die.weights == [%{target: 2, weight: 50}] end)
      true
  """
  @spec add_weight(Dice.t(), list(WeightedRandom.Utils.Types.weight_spec())) :: Dice.t()
  def add_weight(dice, weight) do
    dices = Enum.map(dice.dice, fn die -> Die.add_weight(die, weight) end)
    Map.put(dice, :dice, dices)
  end
end
