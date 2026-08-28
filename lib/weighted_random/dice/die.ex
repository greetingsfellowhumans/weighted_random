defmodule WeightedRandom.Die do
  alias WeightedRandom.Dice.{Opts, Types}
  @moduledoc ~s"""
  A struct and related functions to represent a single die, with any number of sides and weights.

  ```elixir
  iex> :rand.seed(:exsplus, {123, 321, 213})
  iex> alias WeightedRandom.Die
  iex> d = Die.new(%{sides: 6, weights: [%{target: 3, amount: 10}]})
  iex> d = Die.roll(d)
  iex> d.result
  3
  ```


  """
  @enforce_keys [:sides, :weights, :result]
  defstruct sides: 6,
            weights: [],
            preprocessed: nil,
            result: nil

  @type t :: %__MODULE__{
    preprocessed: struct(),
    sides: integer(),
    weights: list(),
    result: any()
  }


  @doc """
  Manually create an individual die struct.

  ## Eamples
      iex> die = Die.new(%{sides: 6})
      iex> die.result >= 1 and die.result <= 6
      true

  Takes a single map as an argument, with the following keys:\n
  #{NimbleOptions.docs(Opts.die_new_body_schema())}
  """
  @spec new(Types.die_spec(), list()) :: __MODULE__.t()
  @spec new(Types.die_spec()) :: __MODULE__.t()
  def new(body, _opts \\ []) do
    struct(__MODULE__, body)
      |> add_preprocess()
      |> roll()
  end

  defp add_preprocess(%__MODULE__{sides: sides, weights: weights} = die) do
    pre = WeightedRandom.preprocess(1..sides, weights, outcome_type: :value)
    Map.put(die, :preprocessed, pre)
  end

  @doc ~S"""
  Reroll a die, randomly picking one of the sides, using the given weights to influence the result.

  ## Examples
      iex> :rand.seed(:exsplus, {123, 321, 213})
      iex> die = Die.new(%{sides: 6, weights: [%{target: 3, amount: 2}]})
      iex> die.result
      3
      iex> Die.roll(die).result
      3
      iex> Die.roll(die).result
      3
      iex> Die.roll(die).result
      3
      iex> Die.roll(die).result
      1
  """
  @spec roll(__MODULE__.t()) :: __MODULE__.t()
  def roll(%__MODULE__{preprocessed: pre} = die) do
    [result] = WeightedRandom.take(pre, 1)

    die
      |> Map.put(:result, result)
  end

  @doc ~s"""
  Given an existing Die struct, add some weights

  ## Examples
      iex> :rand.seed(:exsplus, {123, 321, 213})
      iex> die = Die.new(%{sides: 12})
      iex> die = Die.add_weight(die, [%{target: 5, amount: 50}])
      iex> Die.roll(die).result
      5
  """
  @spec add_weight(__MODULE__.t(), list(WeightedRandom.Utils.Types.weight_spec())) :: __MODULE__.t()
  def add_weight(die, weights) when is_list(weights) do
    Enum.reduce(weights, die, fn w, d -> add_weight(d, w) end)
  end

  @spec add_weight(__MODULE__.t(), WeightedRandom.Utils.Types.weight_spec()) :: __MODULE__.t()
  def add_weight(die, weight) do
    new_weights = [weight | die.weights]
    pre = WeightedRandom.preprocess(1..die.sides, new_weights, outcome_type: :value)
    die
      |> Map.put(:weights, new_weights)
      |> Map.put(:preprocessed, pre)
  end
end
