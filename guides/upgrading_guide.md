# Upgrading Guide

If you are coming to v1.0.0 from v0.4.x, here are some things you should know.

## Why upgrade

- 🚀 Significant performance Improvements
- Much easier to sample a list of results, rather than just one
- Support for probabilities, not just weights
- Better user experience and quality of life improvements
- Polished docs and a livebook tutorial
- swappable backends, not locked into any particular algorithm
- Much more stable and thoroughly tested

## Backward compatibility

In 99% of cases, you should be able to simply update the version without a hitch.

- 🥳 All function contracts from 0.4 have been preserved.
- 🥳 There are many new options, but all old options will still work (except where noted below)

## Breaking changes

- Using seeds to always get the same result. That result will be different now.

```elixir
# If you used seeds to always get the same specific results:
:rand.seed(:exsss, {108, 101, 102})
sample = WeightedRandom.rand(li, weights)
assert sample == 8 # <== Result will be different after upgrading

```

- Similarly, you will get slightly different values from the WeightedRandom.CubicBezier.solve/3 function.

## Soft deprecations

Some options have been changed or renamed, but the original still works in order to maintain backward compatibility.

### Weight maps

- now use the key `:amount` instead of `:weight`.

```elixir
# v0.4.2
WeightedRandom.rand(0..10, [%{target: 5, weight: 42}])

# v1.0.0
WeightedRandom.rand(0..10, [%{target: 5, amount: 42}])
```

Both options still work in v1.0.0 with no issue, but `:amount` is the new convention you will see throughout the docs.

### rand/3 opts

- `[index: true]` is now `[outcome_type: :index]`
- `[index: false]` is now `[outcome_type: :value]`

```elixir
# v0.4.2
WeightedRandom.rand(1..10, weights, index: false)

# v1.0.0
WeightedRandom.rand(1..10, weights, outcome_type: :value)
```

Both options still work in v1.0.0 with no issue, but `:outcome_type` is the new convention you will see throughout the docs.

### CubicBezier

This module is deprecated and you should use the [Curves](https://hex.pm/packages/curves) library instead.
The `solve` function still does work, but it is now a wrapper around Curves.

If you were using the `:duration` option, it no longer does anything.

```elixir
# v0.4.2
y = WeightedRandom.CubicBezier.solve(0.5, :ease_out_quad)

# v1.0.0
curve = Curves.define_bezier(:ease_out_quad)
{x, y} = Curves.solve!(curve, 0.5)
```
