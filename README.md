# WeightedRandom

## Introduction

Sometimes random is *too* random. The WeightedRandom package is a framework manipulating probability.

It is high performance using the Walker-Alias Method by default, but with the ability to easily use plugins or your own algorithm instead. See [WeightedRandom.Backend](lib/weighted_random/backend/backend.ex)
It is approachable, allowing you to start with a list (or range) of possible outcomes, and assume they are all equal weight, until weights are added.
In theory, if you don't add any weights, `WeightedRandom.rand(1..10, [])` is the same as `Enum.rand(1..10)`

Adding [Weights] is simple yet powerful:

- Add multiple weights, picking the index and it's magnitude.
- Add a radius, affecting neighbouring indices, plus an optional bezier curve to determine how to spread out the weight.

## Quick Example

```elixir
iex> alias WeightedRandom, as: WR
iex> # Pick a random number between 1..10, but 4 is 35x more likely than
iex. # any other given number
iex> range = 1..10
iex> weights = [ %{target: 4, weight: 35} ]
iex> table = WR.preprocess(range, weights)
iex> WR.take(table)
4
iex> # You can even set a radius so that neighbouring values also get
iex> # some added weight
iex> weight1 = %{target: 7, weight: 15, radius: 4, curve: :ease_in_sine}
iex> weight2 = %{target: 1, weight: 35}
iex> weights = [weight1, weight2]
iex> table = WR.preprocess(range, weights, index: false)
iex> WR.take(table, 4)
[8, 1, 1, 5, 8, 6, 7, 7, 1, 10]
```

## Visual example

Here I demonstrate picking 10_000 random numbers, and count how many times each
number came up.

Keep in mind that the target is 45. So numbers to the left of it are negative, as far as the curve is concerned. That's why an `ease-in` looks backward to the left, and normal to the right of 45.

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

## Installation

For older versions of elixir (before 1.17) and old OTP (before 27)

```elixir
def deps do
  [
    {:weighted_random, "~> 0.4.2"}
  ]
end
```

For newer projects

```elixir
# mix.exs
def deps do
  [
    {:weighted_random, "~> 1.0.0-beta.0"}
  ]
end

# Optionally if you want to use your own algorithm:
# config.exs
config :weighted_random,
  backend: MyApp.CustomBackEnd

```

## Dice

WeightedRandom also includes a [Dice] rolling module.

```elixir
iex> :rand.seed(:exsss, {100, 231, 302})
iex> import WeightedRandom.Dice
iex> d6 = ~d{6}
iex> d6.total
6
iex> d6 = Dice.roll(d6)
iex> d6.total
3
iex> # You might know this as 4d8+1. or 4 x 8-sided dice, +1 to the total.
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
