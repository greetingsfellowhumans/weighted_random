defmodule WeightedRandom.Backend.WalkerAlias.Table do
  @moduledoc false
  alias WeightedRandom.Backend.WalkerAlias.Buckets.Sorter

  # `take/2` reads only `:bucket_tuple` and `:size`.
  # `:buckets` is a read-only copy kept for backward compatibility; editing it has no effect.
  defstruct [
    :buckets,
    :bucket_tuple,
    :size
  ]

  def new(%Sorter{buckets: buckets}) do
    bucket_tuple = List.to_tuple(buckets)
    struct!(__MODULE__, %{buckets: buckets, bucket_tuple: bucket_tuple, size: tuple_size(bucket_tuple)})
  end
end
