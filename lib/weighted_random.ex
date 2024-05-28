defmodule WeightedRandom do
  alias WeightedRandom.Weight
  @moduledoc """
    Sometimes random is *too* random. Use this to add a bias toward a certain value (or values)
    Also supports such values impacting their neighbours

    Not intended to be cryptographically secure.
    Also not nearly as performant as a simple Enum.random/1, so consider whether you actually need this.
  """

  @doc ~s"""
  Takes a list or range of values, and another list of weights.

  Every value in the range automatically gets a weight of 1.
  When you pass in `%{target: 25, weight: 2}` this is actually ADDING 2 to the total number of 'votes' that 25 gets.

  And when you add a radius: Now the surrounding values also get a boost.


  As an example: `%{target: 10, weight: 10, radius: 3}`
  - there are 3 extra votes for 8
  - there are 7 extra votes for 9
  - There are 10 extra votes for 10
  - there are 7 extra votes for 11
  - there are 3 extra votes for 12

  (Yes the numbers are rounded)

  And this is only using a linear curve. You could also pass in something like:
  
  `%{target: 10, weight: 10, radius: 3, curve: :ease_out}`

  Which will change how much of a boost goes to the surrounding values caught in the radius.

  ## Allowed Curve Types
  ```elixir
  :linear (default)
  :ease
  :ease_in
  :ease_out
  :ease_in_out
  :ease_in_quad
  :ease_in_cubic
  :ease_in_quart
  :ease_in_quint
  :ease_in_sine
  :ease_in_expo
  :ease_in_circ
  :ease_in_back
  :ease_out_quad
  :ease_out_cubic
  :ease_out_quart
  :ease_out_quint
  :ease_out_sine
  :ease_out_expo
  :ease_out_circ
  :ease_out_back
  :ease_in_out_quad
  :ease_in_out_cubic
  :ease_in_out_quart
  :ease_in_out_quint
  :ease_in_out_sine
  :ease_in_out_expo
  :ease_in_out_circ
  :ease_in_out_back
  ```

  ## Examples
      iex> # You won't need this. It's only necessary for consistent test results.
      iex> :rand.seed(:exsss, {100, 101, 102})
      iex> #
      iex> # the result 2 is 10 times more likely to appear than any other number
      iex> range = 1..10
      iex> weights = [%{target: 2, weight: 10}]
      iex> values = Stream.repeatedly(fn -> rand(range, weights) end) |> Enum.take(10)
      [4, 2, 2, 4, 4, 2, 2, 9, 10, 2]
      iex> #
      iex> # Here, the radius of 5 means that extra weight is given to 20..24 and 26..30
      iex> range = 1..50
      iex> weights = [%{target: 25, weight: 10, radius: 5}]
      iex> values = Stream.repeatedly(fn -> rand(range, weights) end) |> Enum.take(10)
      [26, 28, 23, 27, 28, 25, 21, 23, 25, 8]
      iex> range = [true, false, nil, "Apples", :boat]
      iex> # We are not limited to integers
      iex> weights = [%{target: 3, weight: 995}]
      iex> values = Stream.repeatedly(fn -> rand(range, weights) end) |> Enum.take(10)
      [26, 28, 23, 27, 28, 25, 21, 23, 25, 8]
  """
  #@spec rand(li :: list(), list(weights.t()))
  def rand(li, weights, opts \\ []) do
    custom_weights = Enum.map(weights, &(Weight.new(&1, opts)))
    side_effects = Enum.map(custom_weights, &Weight.create_side_effect_weights/1)

    li =
      (Weight.convert_to_values(custom_weights)
      ++ Weight.convert_to_values(side_effects)
      ++ Enum.map(li, &(&1)))
      |> Enum.filter(&(&1 in li))

    Enum.random(li)
  end

  # {{{ Deprecated
  @doc false
  @deprecated "Please use `Enum.random` instead"
  def between(min, max), do: Enum.random(min..max)

  @doc false
  @deprecated "Please use `Enum.take_random` instead"
  def numList(min, max, length) do
    Enum.reduce(0..length, [], fn(_, acc) -> [between(min, max) | acc] end)
  end

  @doc false
  @deprecated "Please use WeightedRandom.rand instead"
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

  @doc false
  @deprecated "Please use WeightedRandom.rand instead"
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
