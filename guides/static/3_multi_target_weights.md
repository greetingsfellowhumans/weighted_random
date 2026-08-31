# 3. Multi-Target Weights

```elixir
# Before getting into the nitty gritty, let's start with a visual demo.
# Without any weights, every outcome has an equal chance of being drawn.
# For example, when picking a random number between 1-4, each outcome has a 25% chance.

# Notice how the lines are pretty even


#### Controls ####
outcomes = 0..4
sample_size = 1000
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
# Watch what happens when the number 3 is 10x more likely to appear than any other number

#### Controls ####
outcomes = 0..4
sample_size = 1000
weights = [
  %{target: 3, weight: 10}
]
####


table = WeightedRandom.preprocess(outcomes, weights)
results = WeightedRandom.take(table, sample_size)

results
|> WeightedRandom.Utils.Plotting.results_to_bars()
|> Tucan.bar("outcome", "hits", height: 200, width: 500, fill_color: "#33245A", corner_radius: 5)
```

```elixir
# Another way to do that is to use a list of probabilities, 
# instead of outcomes + weights


#### Controls ####
sample_size = 1000
probabilities = [
  0.01, 0.01, 0.97, 0.01
]

# alternately, as fractions
# probabilities = [1 / 100, 1 / 100, 97 / 100, 1 / 100]

####

# Notice we use `preprocess_p/1` instead of `preprocess/1`
# The `_p` is for probabilities.
table = WeightedRandom.preprocess_p(probabilities)
results = WeightedRandom.take(table, sample_size)

results
|> WeightedRandom.Utils.Plotting.results_to_bars()
|> Tucan.bar("outcome", "hits", height: 200, width: 500, fill_color: "#33245A", corner_radius: 5)
```

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

table = WeightedRandom.preprocess(outcomes, weights)
results = WeightedRandom.take(table, sample_size)

results
|> WeightedRandom.Utils.Plotting.results_to_bars()
|> Tucan.bar("outcome", "hits", height: 200, width: 500, fill_color: "#33245A", corner_radius: 5)
```

```elixir
#### Using the Curves library  ####

# WeightedRandom weights can easily follow bezier curves.
# let's set up a select list to be used in the next code block    
# That way, we can pick different curves and watch how they affect the randomness.
types = Curves.Bezier.Predefined.list()
|> Enum.map(&{&1, &1})

bezier_type = Kino.Input.select("Curve Type", types, default: :ease_in_out)

```

```elixir
# By using different predefined curves, we clearly get very distinct shapes
# (Of course, some curves work better than others when doing this)

#### Controls ####
length = 100
outcomes = 0..length
sample_size = 1_000_000
curve = Kino.Input.read(bezier_type) # Use the select list above this code block
####

weights = [%{target: round(length / 2), weight: 100, left_dist: round(length / 4), right_dist: round(length / 4), curve: curve}]
table = WeightedRandom.preprocess(outcomes, weights)
results = WeightedRandom.take(table, sample_size)

results
|> WeightedRandom.Utils.Plotting.results_to_bars()
|> Tucan.bar("outcome", "hits", height: 300, width: 300, fill_color: "#33245A", corner_radius: 5)
```

```elixir
# So you can also use your own custom bezier curve.

# Unfortunately, due to some 'mathy' reasons about probabilities not being
#   the same as coordinates on a graph, your results will often look 'flatter' or 
#   more linear than the actual bezier curve.

# So it is best to keep your curves simple and not rely too much on matching them


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
table = WeightedRandom.preprocess(outcomes, weights)
results = WeightedRandom.take(table, sample_size)

results
|> WeightedRandom.Utils.Plotting.results_to_bars()
|> Tucan.bar("outcome", "hits", height: 300, width: 300, fill_color: "#33245A", corner_radius: 5)
```

```elixir
## Dice
alias WeightedRandom.Dice
import Dice

# This creates 4 x 6-sided dice
# In standard dice notation this would be written as "4d6"
d = ~d{4, 6}

# Now let's make the number 2 have more weight
# Dice always use outcome_type: :value, not :index, so the target is 2
weights = [%{target: 2, amount: 50}]
d = Dice.add_weight(d, weights)
d = Dice.roll(d)

IO.inspect(Dice.results(d), label: "results")
d.total
```

```elixir
# We can also add modifiers to the dice notation.
# for example 2d8+1 would create 2 x 8-sided dice, and add +1 to the total
d = ~d{2, 8, 1}
    |> Dice.roll()

IO.inspect(Dice.results(d), label: "results")
d.total
```
