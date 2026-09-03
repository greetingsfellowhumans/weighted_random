defmodule WeightedRandom.Backend.WalkerAlias2.Table do
  alias WeightedRandom.Backend.WalkerAlias2.Buckets.Sorter
  defstruct [
    :buckets
  ]

  def new(%Sorter{buckets: buckets}) do
    struct!(__MODULE__, %{buckets: buckets})
  end
end

