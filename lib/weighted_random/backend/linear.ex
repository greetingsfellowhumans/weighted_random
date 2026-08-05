defmodule WeightedRandom.Backend.Linear do
  @moduledoc ~s"""
  This is a very naive approach. Quick and dirty to implement, but definitely not as fast as most other backends, especially at scale.
  One advantage it has is a very fast and simple preprocessing phase. So if you only need to run it once, this can actually beat the Walker Alias Method.

  ## How it works

  1. Take each probability as a fraction.
  2. Create a list in which every outcome is duplicated a number of times equal to its numerator
  3. take randomly from the list.

  So for example, given the outcomes 0..5, and a single weight: %{target: 0, weight: 1},
  the probabilities should look like: 2/6. 1/6, 1/6, 1/6, 1/6, 1/6
  thus, the preprocessed list is [0, 0, 1, 2, 3, 4, 5]
  making index `0` the most likely to be sampled with `Enum.random(list)`
  """
  use WeightedRandom.Backend

  defstruct [
    li: [],
  ]

  @impl true
  def options() do
    [probability_type: :fraction]
  end

  @impl true
  def preprocess(probabilities, _opts) do
    probabilities = Enum.with_index(probabilities)
    li = Enum.map(probabilities, fn {{weight, _total}, idx} ->
      List.duplicate(idx, round(weight))
    end)
      |> List.flatten()
    struct(__MODULE__, %{li: li})
  end

  @impl true
  def take(%__MODULE__{li: li}, count, _opts) do
    Enum.take_random(li, count)
  end

end
