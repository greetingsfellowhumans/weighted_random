# WeightedRandom

## Introduction

Sometimes random is *too* random. The WeightedRandom package is a framework manipulating probability.

This library is:

- high performance
- approachable, with an interactive [Livebook](tutorial.livemd) tutorial

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
    {:weighted_random, "~> 1.4.2"}
  ]
end
```

For newer projects

```elixir
# mix.exs
def deps do
  [
    {:weighted_random, "~> 1.0.0-alpha.1"}
  ]
end
```
