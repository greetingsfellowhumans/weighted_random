# WeightedRandom

## Installation

```elixir
def deps do
  [
    {:weighted_random, "~> 0.3.0"}
  ]
end
```

## Introduction

Sometimes random is *too* random. Use this to add a bias toward a
certain value (or values)
Also supports such values impacting their neighbours

Not intended to be cryptographically secure.
Also not nearly as performant as a simple Enum.random/1, so consider whether
you actually need this.

## Quick Example

```elixir
iex> import WeightedRandom
iex> # Pick a random number between 1..10, but 4 is 35x more likely than
iex. # any other given number
iex> range = 1..10
iex> weight1 = %{target: 4, weight: 35}
iex> rand(range, weight1)
4
iex> # Multiple weights are supported
iex> # You can even set a radius so that neighbouring values also get
iex> # some added weight
iex> weight1 = %{target: 7, weight: 15, radius: 4, curve: :ease_in_sine}
iex> weight2 = %{target: 1, weight: 35}
iex> weights = [weight1, weight2]
iex> s = Stream.repeatedly(fn -> rand(range, weights, index: false) end)
iex> Enum.take(s, 10)
[8, 1, 1, 5, 8, 6, 7, 7, 1, 10]
```

As a visual aid, I think of it like simulating gravity in spacetime.

![Simulate Gravity](https://upload.wikimedia.org/wikipedia/commons/f/f3/Schwarzchild-metric.jpg)

For more details:
[Hex Docs](https://hexdocs.pm/weighted_random/WeightedRandom.html)
