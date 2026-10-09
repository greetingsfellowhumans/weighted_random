defmodule WeightedRandom.Backend.Linear do
  @moduledoc ~s"""
  This is a very naive approach. Quick and dirty to implement, but definitely not as fast as most other backends, especially at scale.
  One advantage it has is a very fast and simple preprocessing phase. So if you only need to run it once or twice at a time, this can actually beat the Walker Alias Method.

  ## How it works

  1. During preprocessing, build a list of running totals of the weights, e.g. `[1.0, 2.5, 3.0]`.
  2. During `take`, pick a random point between `0` and the total weight.
  3. Walk the list and return the index of the first running total greater than that point.
     Higher weights cover a wider span, so they are picked more often.

  """
  use WeightedRandom.Backend

  # `:li` is kept for backward compatibility with code that reads the struct directly.
  # It is no longer used by `take/2`. Deprecated; remove in 2.0.
  defstruct [
    li: [],
    cumulative: [],
    total: 0.0
  ]

  @impl true
  def options() do
    [probability_type: :weights]
  end

  @impl true
  def preprocess(weights, _opts) do
    {cumulative, total} = Enum.map_reduce(weights, 0.0, fn w, acc -> {acc + w, acc + w} end)

    li =
      weights
      |> Enum.with_index()
      |> Enum.flat_map(fn {weight, idx} -> List.duplicate(idx, round(weight)) end)

    struct(__MODULE__, %{li: li, cumulative: cumulative, total: total})
  end

  @impl true
  def take(%__MODULE__{cumulative: cumulative, total: total}, count) do
    for _ <- 1..count do
      point = :rand.uniform() * total
      Enum.find_index(cumulative, &(point < &1))
    end
  end

end
