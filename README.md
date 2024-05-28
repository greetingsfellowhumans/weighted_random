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

Sometimes random is *too* random. Use this to add a bias toward a certain value (or values)
Also supports such values impacting their neighbours

Not intended to be cryptographically secure.
Also not nearly as performant as a simple Enum.random/1, so consider whether you actually need this.

## Quickstart
```elixir
iex> range = 1..10
iex> weights = [%{target: 2, weight: 10}]
iex> rand(range, weights, index: false)
[7, 2, 2, 7, 2, 2, 1, 7, 2, 8]
```

See the [Hex Docs](https://hexdocs.pm/weighted_random/WeightedRandom.html) for more details.
