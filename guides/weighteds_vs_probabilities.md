# Weights vs Probabilities
Weights eventually get converted into probabilities under the hood. Here are a few differences to keep in mind.

### Adding to one takes from others
You can *add* weights to a target to make it more likely to appear as a result. Doing so makes ALL other outcomes less likely to appear as results, an they are all affected evenly.

Probabilities are floats that should add up to 1.0 (within a reasonable margin of rounding error. More on that later).
So any time you increase one probability, you need to *subtract* from one or many of the other probabilities.
This gives you finer control, but is more manual work and risk of human error.

### Coupling of outcomes

Weights force you to manually pass in a list of possible outcomes.
*The target of a weight is an index of an outcome*
So if your outcomes are `100..200` then a weight of `%{target: 4, ...}` would influence the outcome `104`, not the literal value `4`.
You can change that by passing in the option `[outcome_type: :value]`. Now the weight should be `%{target: 104, ...}`

Probabilities on the other hand implicitly create a list of outcomes from their indices.
So if `probabilities = [0.75, 0.25]`, then we have two possible outcomes: `0` with a 75% chance, and `1` with a 25% chance.

