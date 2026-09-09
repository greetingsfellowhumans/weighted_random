defmodule WeightedRandom.Backend.WalkerAlias.Table do
  @moduledoc false
  alias WeightedRandom.Backend.WalkerAlias.Buckets.Sorter
  defstruct [
    :buckets
  ]

  def new(%Sorter{buckets: buckets}) do
    struct!(__MODULE__, %{buckets: buckets})
  end
end

