# WeightedRandom

## Current state of the project

Version 1.0.0: In alpha. Actively being developed.
Version 0.4.x: Stable.

Improvements in v1.0.0:

- Significant performance Improvements
- Support for probabilities, not just weights
- Better user experience and quality of life improvements
- Polished docs and a livebook tutorial
- extensible backends, swap in different algorithms

## Introduction

Use this lib similar to `Enum.random/1`, except you can add weights to some of the items in the list you passed in.
There are many different options and tools (especially in the upcoming v1)

See [Hex docs](https://weighted-random.hexdocs.pm/1.0.0-alpha.1/WeightedRandom.html). I will not keep documentation in the README.

## Quick example

Pick a random number between 0 and 10, but 7 is 50x more likely than any other number to occur.

```elixir
iex> outcomes = 0..10
iex> weights = [ %{target: 7, weight: 50} ]
ieX> WeightedRandom.rand(outcomes, weights)
7
```
