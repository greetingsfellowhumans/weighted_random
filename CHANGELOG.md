# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased [1.0.0-alpha.2] - 2026-09-30

### Changed

- Increased version of :curves dependency
- Revamped documentation, added typespecs to all documented functions
- More thorough prop testing
- Added string support to sigil_d.

## [1.0.0-alpha.1] - 2026-08-26

This is a big one. I got frustrated and ended up just rewriting a massive amount of code from scratch.

### Removed

- `WeightedRandom.CubicBezier` -> Use `:curves` library instead. [Curves](https://hex.pm/packages/curves)
- `WeightedRandom.Weight` -> Use `WeightedRandom.Input.Weight` instead
- `WeightedRandom.Probability` -> Use `WeightedRandom.Input` and its submodules instead

### Added

- livebook guide with visual demo
- Finer control over radiating weights. instead of only `:radius`, there are now options for `:left_dist` and `:right_dist`
- Support for using a list of probabilities, rather than outcomes and weights

### Fixed

- Bug in which radius of 0 would break
- Bugs in which the radius curve didn't really work
- Bugs with passing in probabilities instead of weights

### BREAKING CHANGES

Probably a lot. This was such a large scale refactor, I am not sure which edge cases are going to fail. Certainly much of the work from alpha.0, but I am less concerned about that.

- `WeightedRandom.CubicBezier`

## [1.0.0-alpha.0] - 2026-07-31

This release is a massive overhaul, that improves performance and flexibility while *mostly* remaining backwards compatible. See section on breaking changes.

The previous algorithm was incredibly slow at scale (it was just my naïve attempt while I learned programming).
WeightedRandom is now algorithm-agnostic! Rather than one hard-coded algo, you can easily switch between backends. The new default one is the excellent Walker Alias Method, via the `wam` hex package. You can still use the original by passing `[backend: WeightedRandom.Backend.Linear]` as an option to `WeightedRandom.rand/3`.

You can also use your own algorithm by passing in any module which `use`s `WeightedRandom.Backend` and implements the behaviour. This way, one can create a new hex package as a plugin, or just make a pull request here.

### BREAKING CHANGES

- Dropped support for older versions of erlang/elixir.
  Minimum supported OTP = 27.0.0
  Minimum supported elixir = 17.0.0
- Dropped `:internal_weight` from `%WeightedRandom.Weighted{}` struct, as it
  was never actually used and just caused confusion.
- When calculating radius, stop rounding the floats. It made sense with a single
  backend that was extremely resource intensive and needed to save bits. But it
  does not make sense as a platform that needs to provide an accurate api.

### Added

- Better documentation and validation of options, using NimbleOptions

## [0.4.2] - 2025-08-04

### Added

Better support for non-integer values 🥳
Previously, you could only have a non-int list / weights if they were based on integer.

Also greatly expanded tests and docs.
Some slight refactoring, but it should not be breaking.

## [0.4.1] - 2025-04-05

### Added

Livebook tutorial

## [0.4.0] - 2025-03-29

### Added

WeightedRandom.Dice Module
We now have the ability to create an arbitrary number of dice, with customizable numbers of sides, which may or may not be weighted using the existing WeightedRandom system.

Although this is a minor version change, there are no breaking changes.

## [0.3.1] - 2024-09-22

### Added

The weights argument for rand/3 can now be a map, in case you only have one weight

### Changed

Improved Docs slightly

## [0.3.0] - 2024-05-27

### Changed

- Transferred ownership of the repo between two of my accounts.
- Updated Readme and docs

## [0.2.0] - 2024-05-27

This is a complete rebuild, and several functions are now deprecated.

### Added

- WeightedRandom.rand/3
- Support for weights having a gravitational effect on surrounding values
  withing a specific radius
- Support for that effect working on a number of different bezier curves

### Deprecated

In the interest of being a good library maintainer, I do not believe in making
breaking changes ever. So the deprecated functions will continue to exist,
undocumented and unmaintained.

I wrote this library when I was first learning Elixir. I had no idea two of
these functions already exist in the core library.
The others are simply replaced by `rand`

#### within the WeightedRandom module

- between
- numList
- weighted
- complex
