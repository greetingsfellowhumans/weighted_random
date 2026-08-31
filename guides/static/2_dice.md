# 2. Dice

Weighted Random can also implement dice.

```elixir
alias WeightedRandom.{Dice, Die}
# Die is singular, Dice are plural.


import Dice
# This dice notation syntax is saying "Give me 3 dice, each with 6 sides"
dice = ~d"3d6"

Dice.results(dice)
#=> [1, 5, 2]

dice.total
#=> 8
```

Let's add weights to the dice.

Note that dice weights *never* target the index. only the actual value. In `WeightedRandom.rand/3`, that would be equal to passing in the opts `[outcome_type: :value]` automatically.

```elixir
dice = Dice.add_weight(~d"10d6", [%{target: 5, amount: 5}])
       |> Dice.roll() # You must re-roll the dice or weights have no effect.

Dice.results(dice)
#=> [5, 3, 1, 5, 3, 5, 4, 5, 5, 6]

dice.total
#=> 42
```

A quick note about the ~d sigil: You can add a modifier to the roll. This has no effect on the results, but it will change the total amount.

```elixir
dice = ~d"2d6+3" # modifiers can also be negative. e.g. ~d"2d6-3"

Dice.results(dice)
#=> [3, 5]

dice.total
#=> 11
```

```elixir
# Another syntax is tuple.
dice = ~d{2, 6, -3}

Dice.results(dice)
#=> [3, 4]

dice.total
#=> 4
```

You can combine different types of dice together.

```elixir
d12s = Dice.add_weight(~d"2d12-1", [%{target: 12, amount: 144}])
d4s = Dice.add_weight(~d"2d4", [%{target: 4, amount: 16}])
dice = Dice.merge_dice([d12s, d4s])

dice = Dice.roll(dice)

Dice.results(dice)
#=> [12, 12, 1, 4]

dice.total
#=> 28
```

It is even possible to create a single die. You must do that manually, without the ~d sigil.

```elixir
d3 = Die.new(%{sides: 3})
d8 = Die.new(%{sides: 8, weights: [%{target: 8, amount: 10}]})

# a die cannot have modifiers. Only groups of dice.
# You can create dice from a list of individual die structs.
dice = Dice.new(%{dice: [d3, d8], modifier: 1})
       |> Dice.roll()

Dice.results(dice)
#=> [1, 8]

dice.total
#=> 10
```
