# Upgrading Guide

If you are coming to v1.0.0 from v0.4.x, here are some things you should know.

## Breaking changes

- The way random numbers are calculated has changed dramatically. So if you were hard-coding a random seed, and relyng on getting the same results every time, then those are going to break.
- Similarly, the CubicBezier module has been retired in favour of [Curves](https://hex.pm/packages/curves), which calculates bezier curves differently. You cannot rely on getting precisely the same results.

## Soft deprecations

Some options have been changed or renamed, but the original still works in order to maintain backward compatibility.

### Weight maps

- now use the key `:amount` instead of `:weight`.

### rand/3 opts

- `[index: true]` is now `[outcome_type: :index]`
- `[index: false]` is now `[outcome_type: :value]`

### CubicBezier

This module is deprecated and you should use the [Curves](https://hex.pm/packages/curves) library instead.
The `solve` function still does work, but it is now a wrapper around Curves.

If you were using the `:duration` option, it no longer does anything.
