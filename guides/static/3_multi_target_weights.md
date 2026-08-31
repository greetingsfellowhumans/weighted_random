# 3. Multi-Target Weights

```elixir
# Before getting into the nitty gritty, let's start with a visual demo.
# Without any weights, every outcome has an equal chance of being drawn.
# For example, when picking a random number between 0-3, each outcome has a 25% chance.

# Notice how the lines are pretty even


#### Controls ####
outcomes = 0..3
sample_size = 5000
####


weights = []
table = WeightedRandom.preprocess(outcomes, weights)

### This is equal to: ###
# for 1..sample_size do
#   Enum.random(outcomes)
# end
WeightedRandom.take(table, sample_size)

```

![Uniform](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/uniform.png)

```elixir
# By default, every number has a weight of 1.
# Let's add a little weight to the index 2

#### Controls ####
outcomes = 0..3
sample_size = 5000
weights = [
  %{target: 2, weight: 0.8}
]
####


WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(sample_size)
```

![Small Weight](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/small_weight.png)

```elixir
# Another way to do that is to use a list of probabilities, 
# instead of outcomes + weights


#### Controls ####
sample_size = 1000
probabilities = [
  0.3, 0.05, 0.6, 0.05
]


####

# Notice we use `preprocess_p/1` instead of `preprocess/1`
# The `_p` is for probabilities.
WeightedRandom.preprocess_p(probabilities)
|> WeightedRandom.take(sample_size)
```

![Probabilities](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/probabilities.png)

```elixir
# We can have more than one weight, too


#### Controls ####
sample_size = 1000
outcomes = 0..20
weights = [
  %{target: 6, weight: 5},
  %{target: 15, weight: 5}
]
####

WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(sample_size)
```

![Two Weights](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/two_weights.png)

```elixir
# By using different predefined curves, we clearly get very distinct shapes
# (Of course, some curves work better than others when doing this)

#### Controls ####
outcomes = 0..100
sample_size = 1_000_000
curve = :ease_in_out
####

weights = [%{target: 50, weight: 100, left_dist: 25, right_dist: 25, curve: curve}]
WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(sample_size)
```

![Ease In Out](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/ease_in_out.png)

```elixir
# Define your own bezier curves


#### Controls ####
length = 100
outcomes = 0..length
sample_size = 1_000_000
curve = [
  {0, 0},
  {0.33, -4},
  {0.67, 4},
  {1, 1}
]

####
weights = [%{target: round(length / 2), weight: 200, left_dist: round(length / 4), right_dist: round(length / 4), curve: curve}]
WeightedRandom.preprocess(outcomes, weights)
|> WeightedRandom.take(sample_size)
```

![Custom Curve](https://github.com/greetingsfellowhumans/weighted_random/raw/master/assets/examples/custom_curve.png)
