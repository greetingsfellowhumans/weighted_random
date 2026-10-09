defmodule WeightedRandom.Backend.Linear do
  @moduledoc ~s"""
  This is a very naive approach. Quick and dirty to implement, but definitely not as fast as most other backends, especially at scale.
  One advantage it has is a very fast and simple preprocessing phase. So if you only need to run it once, this can actually beat the Walker Alias Method.

  ## How it works

  1. Create a list in which every outcome is duplicated, a number of times equal to its weight.
  2. Higher weight outcomes appear more often in the list.
  3. During `take`, the list is passed into `Enum.random/1`

  """
  use WeightedRandom.Backend

  defstruct [
    li: [],
  ]

  @impl true
  def options() do
    [probability_type: :weights]
  end

  @impl true
  def preprocess(weights, _opts) do
    li =
      weights
      |> Enum.with_index()
      |> Enum.flat_map(fn {weight, idx} -> List.duplicate(idx, round(weight)) end)

    struct(__MODULE__, %{li: li})
  end

  @impl true
  def take(%__MODULE__{li: li}, count) do
    for _ <- 1..count do
      Enum.random(li)
    end
  end

end
