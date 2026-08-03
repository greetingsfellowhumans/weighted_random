defmodule WeightedRandom.Backend.WalkerAlias do
  use WeightedRandom.Backend

  @impl true
  def options() do
    [probability_type: :float, with_index: true]
  end

  @impl true
  def preprocess(probabilities, _opts) do
    probabilities
      |> Enum.map(fn {prob, idx} -> {idx, prob} end)
      |> WAM.new()
  end

  @impl true
  def take(table, count) do
    for _ <- 1..count do
      WAM.get(table, :rand.uniform(table.size) - 1, :rand.uniform())
    end
  end

end
