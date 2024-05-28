defmodule WeightedRandom do
  @moduledoc """
    Elixir functions for weighted random.
    Not intended to be cryptographically secure.
  """

  @doc ~s"""
  Takes a list or range of values, and another list of weights.
  ## Examples
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> range = 1..100
      iex> weights = [%{target: 25, weight: 10}]
      iex> rand(range, weights)
  """
  def rand(li, weights, opts \\ []) do
    base_weights =
      li
      |> Enum.map(&(WeightedRandom.Weight.new(%{target: &1}, opts)))
      |> Enum.with_index()

    custom_weights = Enum.map(weights, &(WeightedRandom.Weight.new(&1, opts)))
  end

  # {{{ Deprecated
  @doc """
    Returns an integer between min and max.

  ## Examples
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> WeightedRandom.between(1, 3)
      2
  """
  def between(min, max), do: Enum.random(min..max)

  @doc """
    Returns a list of random integers, all between min and max.

  ## Examples
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> WeightedRandom.numList(0, 100, 10)
      [90, 49, 56, 90, 4, 7, 35, 83, 65, 20, 41]
  """
  def numList(min, max, length) do
    Enum.reduce(0..length, [], fn(_, acc) -> [between(min, max) | acc] end)
  end

  @doc """
    Gets a random number between min and max.  

    If the weight is 1, then it's purely random.  

    If the weight is higher, then the number will *probably* be closer to the target.  

    The higher the weight, the closer to the target.  

    Weights must be positive integers.

  ## Examples
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> WeightedRandom.weighted(0, 100, 75, 10)
      83
  """
  def weighted(min, max, target, weight) do
    range = numList(min, max, weight)

    Enum.reduce(range, min, fn(curr, acc) ->
      new = abs(target - curr)
      old = abs(target - acc)
      closer = new < old
      case closer do
        true -> curr
        false -> acc
      end end)
  end

  @doc """
    Takes a list of maps, each with a value and weight. Returns the value of a randomly picked map.  

    If each map has the same weight, they will all be equally likely to be returned.  
    A map with a relatively higher weight will be more likely to have it's value returned.  

    Weights must be positive integers.

  ## Examples
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> maplist = [ %{:value => :red, :weight => 15}, %{:value => :blue, :weight => 1}, %{:value => :yellow, :weight => 5} ]
      iex> WeightedRandom.complex(maplist)
      :red
  """
  def complex(maplist) do
      result = Enum.reduce(maplist, %{:roll => 0, :value => nil}, fn(%{:value => value, :weight => weight}, acc) ->
          roll = weighted(0, 100, 100, weight)
          closer = roll > acc.roll
          case closer do
              true -> %{:roll => roll, :value => value}
              false -> acc
          end
      end)
      result.value
  end
  # }}}

end
