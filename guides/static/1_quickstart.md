# 1. Basics

The most optimal workflow is to:

1. Define your requirements (outcomes, weights, probabilities, other options)
2. Preprocess it to create a struct that is optimized for making future sampling faster
3. Take n random values

### Randomness from probabilities

```elixir
# Probabilities are floats representing percentages, that should add up to 1.0
probabilities = [0.1, 0.6, 0.2, 0.1]
optimized_struct = WeightedRandom.preprocess_p(probabilities)

n = 5
WeightedRandom.take(optimized_struct, n)
#=> [1, 2, 1, 1, 1]
```

Alternately, if you won't need the same probabilities again:

```elixir
probabilities = [0.1, 0.6, 0.2, 0.1]
WeightedRandom.rand_p(probabilities)
#=> 1

opts = [take: 5]
WeightedRandom.rand_p(probabilities, opts)
#=> [2, 1, 1, 2, 1]
```

### Randomness from outcomes and weights

When given 4 equal probabilities (25% each), you could also write them as `[1/4, 1/4, 1/4, 1/4]`.
What if we simplified it into a list of `[1, 1, 1, 1]`, and automatically normalized it to divide each by the whole?
That is exactly what a weight is.

One benefit over probabilities is that you can adjust one weight without needing to manually recalculate all of them.

To use this, we must now decouple the outcomes from the weights. Before, the index of the probability WAS the outcome.

```elixir
outcomes = 0..3
weight = %{target: 1, weight: 2}
opts = []

# under the hood, this creates the probabilities: `[1/5, 2/5, 1/5, 1/5]`
optimized_struct = WeightedRandom.preprocess(outcomes, [weight], opts)

n = 5
WeightedRandom.take(optimized_struct, n)
#=> [2, 1, 1, 0, 1]
```

Be careful to call the right function. The `_p` suffix means it expects probabilities.

| Weights                        | Probabilities                    |
|------------------------------- |--------------------------------- |
| `WeightedRandom.preprocess/3`  | `WeightedRandom.preprocess_p/2`  |
| `WeightedRandom.rand/3`        | `WeightedRandom.rand_p/2`        |
| `WeightedRandom.take/2`        | `WeightedRandom.take/2`          |

Another benefit of weights is that you can do more than random numbers

```elixir
outcomes = ["a", "b", :c, 3.14]
weights = [%{target: 2, amount: 20}]
WeightedRandom.rand(outcomes, weights)
#=> :c
```

Using the `:outcome_type` option, you can even target the value of an outcome, rather than the index.

```elixir
outcomes = ["a", "b", :c, 3.14]
weights = [%{target: "b", amount: 10}]
WeightedRandom.rand(outcomes, weights, outcome_type: :value)
#=> "b"

outcomes = 100..110
weights = [%{target: 104, amount: 20} | weights]
WeightedRandom.rand(outcomes, weights, outcome_type: :value)
#=> 104
```
