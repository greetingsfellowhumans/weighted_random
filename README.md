# README

## Quick example

Pick a random number between 0 and 10, but 7 is 50x more likely than any other number to occur.

```elixir
iex> outcomes = 0..10
iex> weights = [ %{target: 7, weight: 50} ]
iex> WeightedRandom.rand(outcomes, weights)
7
```

## Current state of the project

Version 1.0.0: In alpha. Actively being developed.

Version 0.4.x: Stable.

Improvements in v1.0.0:

- Significant performance Improvements
- Support for probabilities, not just weights
- Better user experience and quality of life improvements
- Polished docs and a livebook tutorial
- swappable backends, not locked into any particular algorithm.

## Docs

See [Hex docs](https://weighted-random.hexdocs.pm/). Documentation will not be kept in the README.

## Examples

Uniform random

```elixir
for 1..5000 do
  Enum.random(0..3)
end
```

![Uniform](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/uniform.png)

```elixir

probabilities = [
  0.3, 0.05, 0.6, 0.05
]
WeightedRandom.preprocess_p(probabilities)
|> WeightedRandom.take(1000)
```

![Probabilities](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/probabilities.png)

```elixir
# Weights offer an alternative syntax to probabilities.
# By default, every number has a weight of 1.
# Let's add a little weight to the outcome of 2 for a total of 1.8

#### Controls ####
outcomes = 0..3
weights = [
  %{target: 2, amount: 0.8}
]
####


WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(5000)
```

![Small Weight](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/small_weight.png)

```elixir
####
# By using different predefined curves, we clearly get very distinct shapes
# (Of course, some curves work better than others when doing this)

curve = :ease_in_out
outcomes = 0..100
weights = [%{target: 50, amount: 100, radius: 25, curve: curve}]
####


WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(1_000_000)
```

![Ease In Out](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/ease_in_out.png)

```elixir
#### Define your own bezier curve ####
curve = [
  {0, 0},
  {0.33, -4},
  {0.67, 4},
  {1, 1}
]
outcomes = 0..100
weights = [%{target: 50, amount: 200, radius: 25, curve: curve}]
####


WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(1_000_000)
```

![Custom Curve](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/custom_curve.png)
