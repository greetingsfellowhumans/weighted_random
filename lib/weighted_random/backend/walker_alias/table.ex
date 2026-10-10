defmodule WeightedRandom.Backend.WalkerAlias.Table do
  @moduledoc false
  alias WeightedRandom.Backend.WalkerAlias.Buckets.Sorter

  # `take/2` reads `:bucket_tuple` and `:size` when `:bucket_tuple` is set.
  # `:buckets` is a read-only copy kept for backward compatibility; editing it has no effect.
  # `:bucket_tuple` is nil when there are too many buckets to fit in a tuple.
  defstruct [
    :buckets,
    :bucket_tuple,
    :size
  ]

  def new(%Sorter{buckets: buckets}), do: from_buckets(buckets)

  def from_buckets(buckets) when is_list(buckets) do
    size = length(buckets)
    bucket_tuple = if size <= WeightedRandom.Backend.max_tuple_size(), do: List.to_tuple(buckets)
    struct!(__MODULE__, %{buckets: buckets, bucket_tuple: bucket_tuple, size: size})
  end
end
