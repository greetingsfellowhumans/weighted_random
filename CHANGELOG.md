# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 0.4.1 - 2025-04-05

### Added

Livebook tutorial

## 0.4.0 - 2025-03-29

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
- Support for weights having a gravitational effect on surrounding values withing a specific radius
- Support for that effect working on a number of different bezier curves

### Deprecated

In the interest of being a good library maintainer, I do not believe in making breaking changes ever. So the deprecated functions will continue to exist, undocumented and unmaintained.

I wrote this library when I was first learning Elixir... I had no idea two of these functions already exist in the core library. The others are simply replaced by `rand`

#### within the WeightedRandom module

- between
- numList
- weighted
- complex
