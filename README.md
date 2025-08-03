# WeightedRandom

## Installation

```elixir
def deps do
  [
    {:weighted_random, "~> 0.4.2"}
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

## Visual example

Here I demonstrate picking 10_000 random numbers, and count how many times each
number came up.

```elixir
range = 1..100
target = 45
weight = 15
radius = 25
```

### Enum.random(1..100)

<img width="441" height="259" alt="Image" src="https://github.com/user-attachments/assets/cd37e0ed-f327-4351-ab04-4bc574b25453" />

### Ease In

<img width="483" height="269" alt="Image" src="https://github.com/user-attachments/assets/d0f505a1-d742-41bc-8710-08d4fa96a253" />

### Ease Out

<img width="473" height="244" alt="Image" src="https://github.com/user-attachments/assets/e91e7161-0703-411a-a403-4b1389f23a9b" />

## Dice

WeightedRandom also includes a Dice rolling module.

```elixir
iex> :rand.seed(:exsss, {100, 231, 302})
iex> import WeightedRandom.Dice
iex> d6 = ~d{6}
iex> d6.total
6
iex> d6 = Dice.roll(d6)
iex> d6.total
3
iex> # You might know this as 4d8+1.
iex> d8s =  ~d{4, 8, 1}
iex> d8s.total
27
iex> d8s = Dice.roll(d8s)
iex> d8s.total
15
iex> mixed_dice = Dice.merge_dice([d6, d8s])
iex> mixed_dice.total == d6.total + d8s.total
true
iex> heavy_d4 = Dice.add_weight(~d{4}, %{weight: 400, target: 4})
iex> heavy_d4.total == 4
iex> mixed_dice = Dice.merge_dice(mixed_dice, heavy_d4)
iex> mixed_dice.total
3 + 15 + 4
```
