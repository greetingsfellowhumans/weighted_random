defmodule WeightedRandom.Backend.WalkerAlias.Table do
  @moduledoc false
  alias WeightedRandom.Backend.WalkerAlias.Buckets.Sorter

  # `:buckets` is kept for code that reads the struct directly.
  # `take/2` uses `:bucket_tuple` for constant-time random access.
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
