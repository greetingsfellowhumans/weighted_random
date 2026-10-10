defmodule WeightedRandom.Backend.Mwc59 do
  @moduledoc false
  # Helpers for sampling with OTP's `:rand.mwc59/1` generator, used by the WalkerAlias and Linear backends.
  # See the "Niche algorithms" section of the `:rand` docs for the recipes used here.
  import Bitwise

  # Seeded from `:rand`, so `:rand.seed/1` still makes the results reproducible.
  def seed(), do: :rand.mwc59_seed(:rand.uniform(1 <<< 58) - 1)

  # An index in `0..(size - 1)`, using truncated multiplication on the top 35 bits of a 59-bit value.
  # With `size` up to the max tuple size (24 bits) the product stays under 59 bits, so no bignums.
  # The bias is at most `size / 2^35`.
  def index(cx, size), do: (size * (:rand.mwc59_value(cx) >>> 24)) >>> 35

  # Like `index/2`, for sizes too large for truncated multiplication. The bias is at most `size / 2^59`.
  def large_index(cx, size), do: rem(:rand.mwc59_value(cx), size)
end
