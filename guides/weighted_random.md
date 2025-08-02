## Weighted Random Guide

Sometimes random is *too* random. Use this to add a bias toward a certain value (or values)
Also supports such values impacting their neighbours

Not intended to be cryptographically secure.
Also not nearly as performant as a simple Enum.random/1, so consider whether you actually need this.

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

## Examples

    iex> # You won't need this. It's only necessary for consistent test results.
    iex> :rand.seed(:exsss, {100, 101, 102})
    iex>
    iex>
    iex> range = 1..10
    iex> weight = %{target: 2, weight: 10}
    iex> Stream.repeatedly(fn -> rand(range, weight, index: false) end) |> Enum.take(10)
    [4, 2, 2, 4, 4, 2, 2, 9, 10, 2]
    iex>
    iex> # As you can see, 2 is 10x more likely to appear than any other given number.
    iex> # But what if we take away the `index: false` option?
    iex> Stream.repeatedly(fn -> rand(range, weight) end) |> Enum.take(10)
    [7, 3, 3, 7, 3, 3, 1, 7, 3, 8]
    iex>
    iex> # Notice that it was biasing toward the INDEX of 2, not the value of 2.
    iex> # This is useful later when we are not simply using integers.
    iex>
    iex> # Let's play with a radius!
    iex> range = 1..50
    iex> weights = [%{target: 25, weight: 20, radius: 5}]
    iex> # Here, the radius of 5 means that extra weight is ALSO given to the 5 values on either side of 25. I.e.: 20..24 and 26..30
    iex> Stream.repeatedly(fn -> rand(range, weights, index: false) end) |> Enum.take(10)
    [29, 35, 27, 23, 25, 23, 24, 17, 23, 27]
    iex>
    iex> # Wow, 8 out of 10 values fall within that radius!
    iex> # And remember, you can pass the :curve option to adjust how the weight
    iex> # is spread out to neighbours.
    iex>
    iex> # We are not limited to integers
    iex> # (Remember it is based off index)
    iex> range = [true, false, nil, "Apples", :boat]
    iex> weights = [%{target: 0, weight: 100}]
    iex> Stream.repeatedly(fn -> rand(range, weights) end) |> Enum.take(3)
    [true, true, true]
    iex>
    iex> ## Finally, there is no limit to how many weights you can use.
    iex> range = 1..10
    iex> weight1 = %{target: 7, weight: 15, radius: 4, curve: :ease_in_sine}
    iex> weight2 = %{target: 1, weight: 35}
    iex> weights = [weight1, weight2]
    iex> Stream.repeatedly(fn -> rand(range, weights, index: false) end) |> Enum.take(10)
    [8, 1, 1, 5, 8, 6, 7, 7, 1, 10]
    iex> # Did you catch that ease_in_sine curve!?
    iex> By default, radius uses a linear curve, but you can change it. See Weight typespec for details.
