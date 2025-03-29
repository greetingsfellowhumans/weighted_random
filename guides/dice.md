## Dice Guide

This allows us to use dice in creative ways (weighted dice are optional).
The ~d sigil can be used to generate dice in a way fairly similar to the standard dice notation used by many tabletop roleplaying games.
But instead of "2d12+1", you would write `~d{2, 12, 1}`

## Examples

    iex> :rand.seed(:exsss, {100, 101, 102})
    iex> alias WeightedRandom.Dice
    iex> import Dice
    iex> d = ~d{4, 6, 1} # Equal to 4d6+1 in standard dice notation
    iex> [die1 | _] = d.dice
    iex> die1
    %WeightedRandom.Die{sides: 6, weights: [], result: 2}
    iex> d.subtotal
    10
    iex> d.total
    11

This is different from simply calling Enum.random/1, because it creates a persistent Dice struct which contains a :dice list. Each die in the list is a persistent Die struct, that has a specific number of sides and weights.

So you would first define the dice, their various options, and then continue calling Dice.roll(dice) as many times as you need.
The final value that you are looking for is under :total.

Examples

```elixir
    iex> :rand.seed(:exsss, {205, 301, 402})
    iex> d = ~d{10, 20} 
    iex> Enum.map(d.dice, &(&1.result))
    [17, 10, 1, 16, 17, 15, 11, 16, 12, 3]
    iex> d.total
    118
    iex> d = Dice.add_weight(d, [%{target: 2, weight: 25}])
    iex> d = Dice.roll(d)
    iex> Enum.map(d.dice, &(&1.result))
    [2, 2, 2, 2, 3, 2, 2, 2, 18, 6]
    iex> d.total
    41
```
