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

![Simulate Gravity](https://upload.wikimedia.org/wikipedia/commons/f/f3/Schwarzchild-metric.jpg)


See the [Hex Docs](https://hexdocs.pm/weighted_random/WeightedRandom.html) for more details, so I don't have to keep the README up to date.
